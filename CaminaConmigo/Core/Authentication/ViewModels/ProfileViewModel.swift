//
//  ProfileViewModel.swift
//  CaminaConmigo
//
//  Created by a on 28-01-25.
//

import SwiftUI // Importa SwiftUI para las interfaces de usuario.
import Firebase // Importa el framework de Firebase para la gestión de bases de datos y almacenamiento.
import FirebaseFirestore // Importa Firestore para trabajar con la base de datos en la nube de Firebase.
import FirebaseStorage // Importa FirebaseStorage para manejar archivos como imágenes.
import FirebaseAuth // Importa FirebaseAuth para la gestión de autenticación de usuarios.

/// ViewModel que gestiona el perfil del usuario, incluyendo su carga, actualización y almacenamiento.
class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile? // El perfil del usuario cargado.
    @Published var isLoading = false // Indica si se está cargando o guardando información.
    @Published var error: String? // Almacena cualquier mensaje de error que ocurra durante las operaciones.
    
    private let db = Firestore.firestore() // Referencia a Firestore para la base de datos.
    private let storage = Storage.storage().reference() // Referencia a Firebase Storage para almacenar archivos como imágenes.

    /// Inicializador que carga el perfil del usuario al inicializar el ViewModel.
    init() {
        loadUserProfile() // Llama a la función para cargar el perfil del usuario.
    }
    
    /// Método para cargar el perfil del usuario desde Firestore.
    func loadUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Obtiene el ID del usuario autenticado.
        
        isLoading = true // Marca que se está cargando el perfil.
        
        db.collection("users").document(userId).getDocument { [weak self] (snapshot: DocumentSnapshot?, error: Error?) in
            DispatchQueue.main.async {
                self?.isLoading = false // Marca que la carga ha finalizado.
                
                if let error = error {
                    self?.error = error.localizedDescription // Almacena el error si ocurre.
                    return
                }
                
                if let data = snapshot?.data(),
                   let profile = try? Firestore.Decoder().decode(UserProfile.self, from: data) {
                    self?.userProfile = profile // Carga el perfil desde los datos de Firestore.
                } else {
                    // Si no existe un perfil, crea uno nuevo.
                    let newProfile = UserProfile(id: userId)
                    self?.userProfile = newProfile
                    self?.saveProfile() // Guarda el nuevo perfil en Firestore.
                }
            }
        }
    }
    
    /// Método para actualizar el nombre del usuario en el perfil.
    func updateName(_ newName: String) {
        guard var profile = userProfile else { return }
        profile.name = newName
        userProfile = profile
        saveProfile() // Guarda los cambios en el perfil.
    }
    
    /// Método para actualizar el nombre de usuario en el perfil.
    func updateUsername(_ newUsername: String) async {
        guard var profile = userProfile else { return }
        
        do {
            // Validar formato del username
            let validation = isUsernameValid(newUsername)
            if !validation.isValid {
                self.error = validation.message
                return
            }
            
            // Verificar si el username ya está en uso (excepto si es el mismo usuario)
            if profile.username != newUsername {
                let isAvailable = try await checkUsernameAvailability(newUsername)
                if !isAvailable {
                    self.error = "Este nombre de usuario ya está en uso"
                    return
                }
            }
            
            // Actualizar el username
            profile.username = newUsername
            userProfile = profile
            try await saveProfileAsync()
            
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    /// Método para actualizar el tipo de perfil en el perfil.
    func updateProfileType(_ newType: String) {
        guard var profile = userProfile else { return }
        profile.profileType = newType
        userProfile = profile
        saveProfile() // Guarda los cambios en el perfil.
    }
    
    /// Método para subir una nueva imagen de perfil a Firebase Storage.
    func uploadProfileImage(_ image: UIImage) {
        guard let userId = Auth.auth().currentUser?.uid,
              let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        isLoading = true // Marca que se está subiendo la imagen.
        let imageRef = storage.child("profile_images/\(userId).jpg") // Referencia para la imagen en Firebase Storage.
        
        imageRef.putData(imageData, metadata: nil) { [weak self] (metadata: StorageMetadata?, error: Error?) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.error = error.localizedDescription // Almacena el error si ocurre.
                    self?.isLoading = false // Marca que terminó el proceso de carga.
                }
                return
            }
            
            // Una vez que la imagen se sube correctamente, obtenemos la URL de la imagen.
            imageRef.downloadURL { [weak self] (url: URL?, error: Error?) in
                DispatchQueue.main.async {
                    self?.isLoading = false // Marca que terminó la descarga.
                    if let error = error {
                        self?.error = error.localizedDescription // Almacena el error si ocurre.
                        return
                    }
                    
                    if let urlString = url?.absoluteString {
                        self?.updateProfilePhotoURL(urlString) // Actualiza la URL de la foto de perfil en el perfil del usuario.
                    }
                }
            }
        }
    }
    
    /// Método privado para actualizar la URL de la foto de perfil en el perfil del usuario.
    private func updateProfilePhotoURL(_ url: String) {
        guard var profile = userProfile else { return }
        profile.photoURL = url // Actualiza la propiedad `photoURL` con la nueva URL.
        userProfile = profile
        saveProfile() // Guarda los cambios en el perfil.
    }
    
    /// Método privado para guardar el perfil actualizado en Firestore.
    private func saveProfile() {
        guard let userId = Auth.auth().currentUser?.uid,
              let profile = userProfile else { return }
        
        do {
            try db.collection("users").document(userId).setData(from: profile) // Guarda el perfil en la base de datos.
        } catch {
            self.error = error.localizedDescription // Almacena el error si ocurre.
        }
    }
    
    private func saveProfileAsync() async throws {
        guard let userId = Auth.auth().currentUser?.uid,
              let profile = userProfile else { return }
        
        try await db.collection("users").document(userId).setData(from: profile)
    }
    
    func isUsernameValid(_ username: String) -> (isValid: Bool, message: String) {
        // Verificar espacios en blanco
        if username.contains(" ") {
            return (false, "El nombre de usuario no puede contener espacios")
        }
        
        // Verificar longitud mínima
        if username.count < 3 {
            return (false, "El nombre de usuario debe tener al menos 3 caracteres")
        }
        
        return (true, "")
    }
    
    func checkUsernameAvailability(_ username: String) async throws -> Bool {
        let snapshot = try await db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments()
        
        // Si no hay documentos, el username está disponible
        return snapshot.documents.isEmpty
    }
}

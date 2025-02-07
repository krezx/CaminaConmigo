//
//  AuthenticationViewModel.swift
//  CaminaConmigo
//
//  Created by a on 28-01-25.
//

import Foundation // Importa el framework Foundation para trabajar con tipos básicos y errores.
import Firebase // Importa Firebase para la autenticación.
import GoogleSignIn // Importa la biblioteca de Google Sign-In para autenticar usuarios con Google.
import FirebaseAuth // Importa FirebaseAuth para gestionar la autenticación de usuarios en Firebase.
import FirebaseFirestore // Importa FirebaseFirestore para trabajar con Firestore.

/// ViewModel que gestiona la autenticación del usuario, utilizando Firebase y Google Sign-In.
class AuthenticationViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User? // Almacena la sesión actual del usuario autenticado.
    @Published var currentUser: User? // Información adicional del usuario (aunque no se utiliza explícitamente en el código).
    @Published var isGuestMode: Bool = false // Indica si el usuario está en modo invitado.
    private let db = Firestore.firestore() // Agregamos referencia a Firestore
    
    /// Inicializador que establece la sesión del usuario si ya está autenticado en Firebase.
    init() {
        self.userSession = Auth.auth().currentUser // Obtiene el usuario actual de Firebase al inicializar el ViewModel.
    }
    
    /// Método para autenticar al usuario mediante Google Sign-In.
    /// - Throws: Lanza errores si ocurre un fallo durante la autenticación.
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Configura la autenticación de Google con el clientID de Firebase.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Obtiene la ventana raíz para presentar el flujo de autenticación de Google.
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first,
              let rootViewController = await window.rootViewController else {
            throw AuthError.noRootViewController // Lanza un error si no se puede obtener la ventana raíz.
        }
        
        do {
            // Inicia el proceso de autenticación con Google.
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            // Verifica si se obtuvo un token de ID de Google.
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.tokenError // Lanza un error si no se obtuvo el token de ID.
            }
            
            // Crea las credenciales de Firebase utilizando el token de Google.
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            // Inicia sesión en Firebase utilizando las credenciales de Google.
            let authResult = try await Auth.auth().signIn(with: credential)
            self.userSession = authResult.user // Establece la sesión del usuario en Firebase.
            
            // Verificar si el usuario ya existe en Firestore
            let userDoc = try await db.collection("users").document(authResult.user.uid).getDocument()
            
            if !userDoc.exists {
                // Solo crear nuevo perfil si el usuario no existe
                let displayName = authResult.user.displayName ?? "Usuario"
                let email = authResult.user.email ?? ""
                // Crear un username único basado en el email
                let baseUsername = email.components(separatedBy: "@").first ?? "user"
                let username = try await generateUniqueUsername(baseUsername: baseUsername)
                
                let userProfile = UserProfile(
                    id: authResult.user.uid,
                    name: displayName,
                    username: username,
                    email: email,
                    profileType: "Público",
                    photoURL: authResult.user.photoURL?.absoluteString
                )
                
                try await db.collection("users").document(authResult.user.uid).setData(from: userProfile)
            }
            
        } catch {
            throw AuthError.signInError // Lanza un error si ocurre un fallo durante el proceso de inicio de sesión.
        }
    }
    
    /// Método para iniciar sesión como invitado, sin autenticación.
    func signInAsGuest() {
        self.isGuestMode = true // Establece que el usuario está en modo invitado.
        self.userSession = nil // No se guarda una sesión de usuario en Firebase.
    }
    
    /// Método para cerrar la sesión del usuario.
    func signOut() {
        if isGuestMode {
            self.isGuestMode = false // Si está en modo invitado, solo desactiva el modo invitado.
        } else {
            do {
                try Auth.auth().signOut() // Intenta cerrar la sesión de Firebase.
                self.userSession = nil // Elimina la sesión del usuario.
                GIDSignIn.sharedInstance.signOut() // Cierra sesión también en Google.
            } catch {
                print("Error al cerrar sesión: \(error.localizedDescription)") // Muestra un mensaje de error si no se puede cerrar sesión.
            }
        }
    }
    
    private func generateUniqueUsername(baseUsername: String) async throws -> String {
        var username = baseUsername
        var counter = 1
        
        while true {
            let snapshot = try await db.collection("users")
                .whereField("username", isEqualTo: username)
                .getDocuments()
            
            if snapshot.documents.isEmpty {
                return username
            }
            
            username = "\(baseUsername)\(counter)"
            counter += 1
        }
    }
}

/// Enum que define los errores posibles en el flujo de autenticación.
enum AuthError: Error {
    case noRootViewController // Error cuando no se puede obtener la ventana raíz para mostrar la interfaz de Google Sign-In.
    case tokenError // Error cuando no se puede obtener el token de ID de Google.
    case signInError // Error general para fallos durante el inicio de sesión.
}

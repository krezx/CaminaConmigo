import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    init() {
        loadUserProfile()
    }
    
    func loadUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        db.collection("users").document(userId).getDocument { [weak self] (snapshot: DocumentSnapshot?, error: Error?) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error.localizedDescription
                    return
                }
                
                if let data = snapshot?.data(),
                   let profile = try? Firestore.Decoder().decode(UserProfile.self, from: data) {
                    self?.userProfile = profile
                } else {
                    // Crear un nuevo perfil si no existe
                    let newProfile = UserProfile(id: userId)
                    self?.userProfile = newProfile
                    self?.saveProfile()
                }
            }
        }
    }
    
    func updateName(_ newName: String) {
        guard var profile = userProfile else { return }
        profile.name = newName
        userProfile = profile
        saveProfile()
    }
    
    func updateUsername(_ newUsername: String) {
        guard var profile = userProfile else { return }
        profile.username = newUsername
        userProfile = profile
        saveProfile()
    }
    
    func updateProfileType(_ newType: String) {
        guard var profile = userProfile else { return }
        profile.profileType = newType
        userProfile = profile
        saveProfile()
    }
    
    func uploadProfileImage(_ image: UIImage) {
        guard let userId = Auth.auth().currentUser?.uid,
              let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        isLoading = true
        let imageRef = storage.child("profile_images/\(userId).jpg")
        
        imageRef.putData(imageData, metadata: nil) { [weak self] (metadata: StorageMetadata?, error: Error?) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.error = error.localizedDescription
                    self?.isLoading = false
                }
                return
            }
            
            imageRef.downloadURL { [weak self] (url: URL?, error: Error?) in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.error = error.localizedDescription
                        return
                    }
                    
                    if let urlString = url?.absoluteString {
                        self?.updateProfilePhotoURL(urlString)
                    }
                }
            }
        }
    }
    
    private func updateProfilePhotoURL(_ url: String) {
        guard var profile = userProfile else { return }
        profile.photoURL = url
        userProfile = profile
        saveProfile()
    }
    
    private func saveProfile() {
        guard let userId = Auth.auth().currentUser?.uid,
              let profile = userProfile else { return }
        
        do {
            try db.collection("users").document(userId).setData(from: profile)
        } catch {
            self.error = error.localizedDescription
        }
    }
} 
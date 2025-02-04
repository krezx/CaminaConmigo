import Foundation
import FirebaseFirestore
import FirebaseAuth

class FriendsViewModel: ObservableObject {
    @Published var friends: [UserProfile] = []
    @Published var error: String?
    @Published var isLoading = false
    private let db = Firestore.firestore()
    
    init() {
        loadFriends()
    }
    
    func loadFriends() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        db.collection("users").document(userId)
            .collection("friends")
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.error = error.localizedDescription
                        return
                    }
                    
                    let friendIds = snapshot?.documents.map { $0.documentID } ?? []
                    self?.loadFriendsProfiles(friendIds: friendIds)
                }
            }
    }
    
    private func loadFriendsProfiles(friendIds: [String]) {
        guard !friendIds.isEmpty else {
            self.friends = []
            return
        }
        
        db.collection("users")
            .whereField(FieldPath.documentID(), in: friendIds)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.error = error.localizedDescription
                    }
                    return
                }
                
                let friends = snapshot?.documents.compactMap { document -> UserProfile? in
                    try? document.data(as: UserProfile.self)
                } ?? []
                
                DispatchQueue.main.async {
                    self?.friends = friends
                }
            }
    }
    
    func addFriend(email: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No hay usuario autenticado"])
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // Buscar usuario por email
        let snapshot = try await db.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments()
        
        guard let friendDoc = snapshot.documents.first,
              friendDoc.documentID != currentUserId else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Usuario no encontrado o es tu propio email"])
        }
        
        // Agregar amigo a la colección de amigos del usuario actual
        try await db.collection("users").document(currentUserId)
            .collection("friends")
            .document(friendDoc.documentID)
            .setData(["addedAt": FieldValue.serverTimestamp()])
        
        // Agregar al usuario actual como amigo del otro usuario
        try await db.collection("users").document(friendDoc.documentID)
            .collection("friends")
            .document(currentUserId)
            .setData(["addedAt": FieldValue.serverTimestamp()])
    }
    
    func removeFriend(friendId: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No hay usuario autenticado"])
        }
        
        // Eliminar amigo de la colección de amigos del usuario actual
        try await db.collection("users").document(currentUserId)
            .collection("friends")
            .document(friendId)
            .delete()
        
        // Eliminar al usuario actual de la colección de amigos del otro usuario
        try await db.collection("users").document(friendId)
            .collection("friends")
            .document(currentUserId)
            .delete()
    }
} 
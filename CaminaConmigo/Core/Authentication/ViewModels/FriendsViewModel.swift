import Foundation
import FirebaseFirestore
import FirebaseAuth

class FriendsViewModel: ObservableObject {
    @Published var friends: [UserProfile] = []
    @Published var friendRequests: [FriendRequest] = []
    @Published var error: String?
    @Published var isLoading = false
    private let db = Firestore.firestore()
    
    init() {
        loadFriends()
        loadFriendRequests()
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
    
    func sendFriendRequest(searchText: String) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No hay usuario autenticado"])
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // Buscar usuario por email o username
        let emailSnapshot = try await db.collection("users")
            .whereField("email", isEqualTo: searchText)
            .getDocuments()
            
        let usernameSnapshot = try await db.collection("users")
            .whereField("username", isEqualTo: searchText)
            .getDocuments()
        
        // Combinar resultados y tomar el primero válido
        let allDocs = emailSnapshot.documents + usernameSnapshot.documents
        guard let friendDoc = allDocs.first(where: { $0.documentID != currentUser.uid }) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Usuario no encontrado o es tu propio usuario"])
        }
        
        // Verificar si ya existe una solicitud pendiente
        let existingRequests = try await db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: currentUser.uid)
            .whereField("toUserId", isEqualTo: friendDoc.documentID)
            .whereField("status", isEqualTo: "pending")
            .getDocuments()
        
        if !existingRequests.documents.isEmpty {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ya existe una solicitud pendiente para este usuario"])
        }
        
        // Verificar si ya son amigos
        let existingFriend = try await db.collection("users")
            .document(currentUser.uid)
            .collection("friends")
            .document(friendDoc.documentID)
            .getDocument()
            
        if existingFriend.exists {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Este usuario ya es tu amigo"])
        }
        
        // Crear la solicitud de amistad
        let friendRequest = FriendRequest(
            fromUserId: currentUser.uid,
            toUserId: friendDoc.documentID,
            status: .pending,
            createdAt: Date(),
            fromUserEmail: currentUser.email ?? "",
            fromUserName: currentUser.displayName ?? ""
        )
        
        // Guardar la solicitud en Firestore
        try await db.collection("friendRequests")
            .document()
            .setData(try Firestore.Encoder().encode(friendRequest))
    }
    
    func loadFriendRequests() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("friendRequests")
            .whereField("toUserId", isEqualTo: userId)
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    self?.error = error.localizedDescription
                    return
                }
                
                self?.friendRequests = snapshot?.documents.compactMap { document in
                    try? document.data(as: FriendRequest.self)
                } ?? []
            }
    }
    
    func handleFriendRequest(_ request: FriendRequest, accept: Bool) async throws {
        guard let requestId = request.id else { return }
        
        let status: FriendRequest.RequestStatus = accept ? .accepted : .rejected
        
        // Actualizar el estado de la solicitud
        try await db.collection("friendRequests")
            .document(requestId)
            .updateData(["status": status.rawValue])
        
        if accept {
            // Si se acepta, agregar a ambos usuarios como amigos
            try await addFriendship(userId1: request.fromUserId, userId2: request.toUserId)
        }
    }
    
    private func addFriendship(userId1: String, userId2: String) async throws {
        // Agregar amigo para el usuario 1
        try await db.collection("users").document(userId1)
            .collection("friends")
            .document(userId2)
            .setData(["addedAt": FieldValue.serverTimestamp()])
        
        // Agregar amigo para el usuario 2
        try await db.collection("users").document(userId2)
            .collection("friends")
            .document(userId1)
            .setData(["addedAt": FieldValue.serverTimestamp()])
    }
} 
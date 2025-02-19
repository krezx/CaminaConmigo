import Foundation
import FirebaseFirestore
import FirebaseAuth

class FriendsViewModel: ObservableObject {
    @Published var friends: [UserProfile] = []
    @Published var friendRequests: [FriendRequest] = []
    @Published var error: String?
    @Published var isLoading = false
    @Published var friendNicknames: [String: String] = [:]
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
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        // Primero, obtener los nicknames de la colección de amigos
        db.collection("users").document(currentUserId)
            .collection("friends")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.error = error.localizedDescription
                    }
                    return
                }
                
                // Crear un diccionario de nicknames por ID de amigo
                let nicknames = Dictionary(uniqueKeysWithValues: snapshot?.documents.compactMap { doc -> (String, String)? in
                    guard let nickname = doc.data()["nickname"] as? String else { return nil }
                    return (doc.documentID, nickname)
                } ?? [])
                
                // Luego, obtener los perfiles completos de los amigos
                self?.db.collection("users")
                    .whereField(FieldPath.documentID(), in: friendIds)
                    .getDocuments { [weak self] snapshot, error in
                        if let error = error {
                            DispatchQueue.main.async {
                                self?.error = error.localizedDescription
                            }
                            return
                        }
                        
                        let friends = snapshot?.documents.compactMap { document -> (UserProfile, String?)? in
                            if let profile = try? document.data(as: UserProfile.self) {
                                // Obtener el nickname si existe
                                let nickname = nicknames[document.documentID]
                                return (profile, nickname)
                            }
                            return nil
                        } ?? []
                        
                        DispatchQueue.main.async {
                            self?.friends = friends.map { profile, nickname in
                                profile // Aquí ya no necesitamos modificar el displayName
                            }
                            // Guardamos los nicknames en una propiedad separada si los necesitamos mostrar en la UI
                            self?.friendNicknames = Dictionary(uniqueKeysWithValues: friends.compactMap { profile, nickname in
                                nickname.map { (profile.id, $0) }
                            })
                        }
                    }
            }
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
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Usuario no encontrado"])
        }
        
        // Verificar si ya existe una solicitud pendiente
        let existingRequests = try await db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: currentUser.uid)
            .whereField("toUserId", isEqualTo: friendDoc.documentID)
            .whereField("status", isEqualTo: FriendRequest.RequestStatus.pending.rawValue)
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
        
        // Obtener el perfil del usuario actual
        let currentUserDoc = try await db.collection("users").document(currentUser.uid).getDocument()
        guard let currentUserProfile = try? currentUserDoc.data(as: UserProfile.self) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error al obtener el perfil del usuario"])
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
        let requestRef = db.collection("friendRequests").document()
        try await requestRef.setData(try Firestore.Encoder().encode(friendRequest))
        
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
            
            // Obtener el perfil del usuario que acepta
            let currentUserDoc = try await db.collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument()
            guard let currentUserProfile = try? currentUserDoc.data(as: UserProfile.self) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error al obtener el perfil del usuario"])
            }
            
            // Crear y guardar la notificación de aceptación
            let notification = UserNotification.createFriendRequestAcceptedNotification(
                forUser: request.fromUserId,
                fromUser: currentUserProfile
            )
            
            try await db.collection("users")
                .document(request.fromUserId)
                .collection("notifications")
                .document()
                .setData(try Firestore.Encoder().encode(notification))
        }
    }
    
    private func addFriendship(userId1: String, userId2: String) async throws {
        // Obtener los perfiles de ambos usuarios
        let user1Doc = try await db.collection("users").document(userId1).getDocument()
        let user2Doc = try await db.collection("users").document(userId2).getDocument()
        
        guard let user1Profile = try? user1Doc.data(as: UserProfile.self),
              let user2Profile = try? user2Doc.data(as: UserProfile.self) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error al obtener perfiles de usuarios"])
        }
        
        // Agregar amigo para el usuario 1
        try await db.collection("users").document(userId1)
            .collection("friends")
            .document(userId2)
            .setData([
                "addedAt": FieldValue.serverTimestamp(),
                "nickname": user2Profile.username // Usar el username como nickname inicial
            ])
        
        // Agregar amigo para el usuario 2
        try await db.collection("users").document(userId2)
            .collection("friends")
            .document(userId1)
            .setData([
                "addedAt": FieldValue.serverTimestamp(),
                "nickname": user1Profile.username // Usar el username como nickname inicial
            ])
        
        // Crear chat para ambos usuarios
        let chatId = UUID().uuidString
        
        // Guardar el chat en la colección de chats
        try await db.collection("chats").document(chatId).setData([
            "participants": [userId1, userId2],
            "lastMessage": "¡Hola! Ahora somos amigos",
            "lastMessageTimestamp": Timestamp(date: Date()),
            "userNames": [
                userId1: user1Profile.username,
                userId2: user2Profile.username
            ]
        ])
    }
    
    // Agregar función para actualizar el nickname de un amigo
    func updateFriendNickname(friendId: String, newNickname: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No hay usuario autenticado"])
        }
        
        try await db.collection("users").document(currentUserId)
            .collection("friends")
            .document(friendId)
            .updateData(["nickname": newNickname])
    }
} 

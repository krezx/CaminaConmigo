import Foundation
import FirebaseFirestore
import FirebaseAuth

class NotificationsViewModel: ObservableObject {
    @Published var friendRequests: [FriendRequest] = []
    @Published var isLoading = false
    @Published var error: String?
    private let db = Firestore.firestore()
    
    init() {
        loadFriendRequests()
    }
    
    func loadFriendRequests() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("friendRequests")
            .whereField("toUserId", isEqualTo: userId)
            .whereField("status", isEqualTo: FriendRequest.RequestStatus.pending.rawValue)
            .order(by: "createdAt", descending: true)
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
        isLoading = true
        defer { isLoading = false }
        
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
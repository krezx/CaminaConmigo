import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications: [UserNotification] = []
    @Published var friendRequests: [FriendRequest] = []
    @Published var isLoading = false
    @Published var error: String?
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        loadNotifications()
        loadFriendRequests()
    }
    
    deinit {
        // Asegurarnos de remover el listener cuando se destruye el ViewModel
        listener?.remove()
    }
    
    func loadNotifications() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Remover el listener anterior si existe
        listener?.remove()
        
        // Crear un nuevo listener
        listener = db.collection("users")
            .document(userId)
            .collection("notifications")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.error = error.localizedDescription
                        return
                    }
                    
                    self.notifications = snapshot?.documents.compactMap { document in
                        try? document.data(as: UserNotification.self)
                    } ?? []
                }
            }
    }
    
    func markNotificationAsRead(_ notification: UserNotification) {
        guard let notificationId = notification.id,
              let userId = Auth.auth().currentUser?.uid else { return }
        
        Task { @MainActor in
            do {
                let updateData: [String: Any] = ["isRead": true]
                try await db.collection("users")
                    .document(userId)
                    .collection("notifications")
                    .document(notificationId)
                    .updateData(updateData)
            } catch {
                print("Error marking notification as read: \(error)")
            }
        }
    }
    
    func markAllNotificationsAsRead() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task { @MainActor in
            do {
                let batch = db.batch()
                
                let unreadNotifications = try await db.collection("users")
                    .document(userId)
                    .collection("notifications")
                    .whereField("isRead", isEqualTo: false)
                    .getDocuments()
                
                // Crear el diccionario de actualización dentro del contexto @MainActor
                await MainActor.run {
                    let updateData: [String: Any] = ["isRead": true]
                    for doc in unreadNotifications.documents {
                        let ref = db.collection("users")
                            .document(userId)
                            .collection("notifications")
                            .document(doc.documentID)
                        batch.updateData(updateData, forDocument: ref)
                    }
                }
                
                try await batch.commit()
            } catch {
                print("Error marking all notifications as read: \(error)")
            }
        }
    }
    
    func loadFriendRequests() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("friendRequests")
            .whereField("toUserId", isEqualTo: userId)
            .whereField("status", isEqualTo: FriendRequest.RequestStatus.pending.rawValue)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.error = error.localizedDescription
                        return
                    }
                    
                    self.friendRequests = snapshot?.documents.compactMap { document in
                        try? document.data(as: FriendRequest.self)
                    } ?? []
                    
                    // Recargar las notificaciones cuando cambian las solicitudes
                    self.loadNotifications()
                }
            }
    }
    
    func handleFriendRequest(_ request: FriendRequest, accept: Bool) async throws {
        isLoading = true
        defer { 
            DispatchQueue.main.async {
                self.isLoading = false
                // Remover la solicitud de la lista local inmediatamente
                self.friendRequests.removeAll { $0.id == request.id }
            }
        }
        
        guard let requestId = request.id else { return }
        
        let status: FriendRequest.RequestStatus = accept ? .accepted : .rejected
        
        // Crear el diccionario de actualización dentro del contexto @MainActor
        let updateData: [String: String] = ["status": status.rawValue]
        
        // Actualizar el estado de la solicitud
        try await db.collection("friendRequests")
            .document(requestId)
            .updateData(updateData)
        
        if accept {
            // Si se acepta, agregar a ambos usuarios como amigos
            try await addFriendship(userId1: request.fromUserId, userId2: request.toUserId)
        }
        
        // Marcar la notificación relacionada como leída
        if let notification = notifications.first(where: { $0.data["requestId"] == requestId }) {
            markNotificationAsRead(notification)
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
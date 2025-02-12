import Foundation
import FirebaseFirestore
import FirebaseAuth

class MenuViewModel: ObservableObject {
    @Published var pendingNotificationsCount: Int = 0
    @Published var unreadMessagesCount: Int = 0
    private var listeners: [ListenerRegistration] = []
    private let db = Firestore.firestore()
    
    init() {
        setupNotificationsListener()
        setupUnreadMessagesListener()
    }
    
    deinit {
        listeners.forEach { $0.remove() }
    }
    
    private func setupNotificationsListener() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let notificationListener = db.collection("users")
            .document(userId)
            .collection("notifications")
            .whereField("isRead", isEqualTo: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error loading notifications count: \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.pendingNotificationsCount = snapshot?.documents.count ?? 0
                }
            }
        
        listeners.append(notificationListener)
    }
    
    private func setupUnreadMessagesListener() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let chatListener = db.collection("chats")
            .whereField("participants", arrayContains: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error loading unread messages count: \(error)")
                    return
                }
                
                let totalUnread = snapshot?.documents.compactMap { document -> Int in
                    let unreadCounts = document.data()["unreadCount"] as? [String: Int] ?? [:]
                    return unreadCounts[userId] ?? 0
                }.reduce(0, +) ?? 0
                
                DispatchQueue.main.async {
                    self.unreadMessagesCount = totalUnread
                }
            }
        
        listeners.append(chatListener)
    }
} 
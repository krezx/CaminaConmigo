import Foundation
import FirebaseFirestore
import FirebaseAuth

class MenuViewModel: ObservableObject {
    @Published var pendingNotificationsCount: Int = 0
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()
    
    init() {
        setupNotificationsListener()
    }
    
    deinit {
        listener?.remove()
    }
    
    private func setupNotificationsListener() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        listener?.remove()
        
        // Escuchar las notificaciones no leídas del usuario
        listener = db.collection("users")
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
    }
} 
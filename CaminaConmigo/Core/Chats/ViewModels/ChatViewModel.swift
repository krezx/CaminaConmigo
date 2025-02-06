import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var chats: [Chat] = []
    @Published var error: String?
    @Published var isLoading = false
    
    private var listenerRegistrations: [ListenerRegistration] = []
    private let db = Firestore.firestore()
    
    deinit {
        // Limpiamos los listeners cuando se destruye el ViewModel
        listenerRegistrations.forEach { $0.remove() }
    }
    
    func listenToChats() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let listener = db.collection("chats")
            .whereField("participants", arrayContains: currentUserId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.chats = []
                    return
                }
                
                self.chats = documents.compactMap { Chat.fromFirestore($0) }
                    .sorted { $0.lastMessageTimestamp > $1.lastMessageTimestamp }
            }
        
        listenerRegistrations.append(listener)
    }
    
    func listenToMessages(in chatId: String) {
        let listener = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.messages = []
                    return
                }
                
                self.messages = documents.compactMap { Message.fromFirestore($0) }
                
                // Marcar mensajes como leídos cuando se cargan
                self.markMessagesAsRead(messages: self.messages, in: chatId)
            }
        
        listenerRegistrations.append(listener)
    }
    
    func sendMessage(_ content: String, in chatId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let message = Message(
            id: UUID().uuidString,
            senderId: currentUserId,
            content: content,
            timestamp: Date(),
            isRead: false
        )
        
        // Añadir mensaje a la colección de mensajes
        db.collection("chats")
            .document(chatId)
            .collection("messages")
            .document(message.id)
            .setData(message.dictionary) { [weak self] error in
                if let error = error {
                    self?.error = error.localizedDescription
                }
            }
        
        // Actualizar último mensaje en el chat
        db.collection("chats")
            .document(chatId)
            .updateData([
                "lastMessage": content,
                "lastMessageTimestamp": Timestamp(date: Date())
            ])
    }
    
    func createNewChat(with userId: String, name: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let chat = Chat(
            id: UUID().uuidString,
            participants: [currentUserId, userId],
            name: name,
            lastMessage: "Nuevo chat creado",
            timeString: DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short),
            lastMessageTimestamp: Date()
        )
        
        db.collection("chats")
            .document(chat.id)
            .setData(chat.dictionary) { [weak self] error in
                if let error = error {
                    self?.error = error.localizedDescription
                }
            }
    }
    
    func createGroupChat(name: String, participants: [String], completion: @escaping (Bool) -> Void) {
        let chat = Chat(
            id: UUID().uuidString,
            participants: participants,
            name: name,
            lastMessage: "Grupo creado",
            timeString: DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short),
            lastMessageTimestamp: Date()
        )
        
        db.collection("chats")
            .document(chat.id)
            .setData(chat.dictionary) { [weak self] error in
                if let error = error {
                    self?.error = error.localizedDescription
                    completion(false)
                } else {
                    completion(true)
                }
            }
    }
    
    private func markMessagesAsRead(messages: [Message], in chatId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let batch = db.batch()
        let unreadMessages = messages.filter { !$0.isRead && $0.senderId != currentUserId }
        
        for message in unreadMessages {
            let messageRef = db.collection("chats")
                .document(chatId)
                .collection("messages")
                .document(message.id)
            
            batch.updateData(["isRead": true], forDocument: messageRef)
        }
        
        if !unreadMessages.isEmpty {
            batch.commit { [weak self] error in
                if let error = error {
                    self?.error = error.localizedDescription
                }
            }
        }
    }
} 
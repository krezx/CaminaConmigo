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
            lastMessageTimestamp: Date(),
            adminId: currentUserId
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
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let chat = Chat(
            id: UUID().uuidString,
            participants: participants,
            name: name,
            lastMessage: "Grupo creado",
            timeString: DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short),
            lastMessageTimestamp: Date(),
            adminId: currentUserId  // El creador del grupo será el administrador
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
    
    func updateNickname(in chatId: String, for userId: String, newNickname: String) async throws {
        // Obtener el documento del chat actual
        let chatDoc = try await db.collection("chats").document(chatId).getDocument()
        var nicknames = (chatDoc.data()?["nicknames"] as? [String: String]) ?? [:]
        
        // Actualizar el apodo para el usuario especificado
        nicknames[userId] = newNickname
        
        // Actualizar el documento en Firestore
        try await db.collection("chats").document(chatId).updateData([
            "nicknames": nicknames
        ])
    }
    
    func updateGroupName(chatId: String, newName: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])
        }
        
        // Verificar que el usuario es el administrador
        let chatDoc = try await db.collection("chats").document(chatId).getDocument()
        guard let adminId = chatDoc.data()?["adminId"] as? String,
              adminId == currentUserId else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Solo el administrador puede editar el nombre del grupo"])
        }
        
        // Actualizar el nombre del grupo
        try await db.collection("chats").document(chatId).updateData([
            "name": newName
        ])
    }
} 

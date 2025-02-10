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
            adminIds: [currentUserId]
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
            adminIds: [currentUserId]  // El creador será el primer administrador
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
        
        // Verificar que el usuario es uno de los administradores
        let chatDoc = try await db.collection("chats").document(chatId).getDocument()
        guard let adminIds = chatDoc.data()?["adminIds"] as? [String],
              adminIds.contains(currentUserId) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Solo los administradores pueden editar el nombre del grupo"])
        }
        
        // Actualizar el nombre del grupo
        try await db.collection("chats").document(chatId).updateData([
            "name": newName
        ])
    }
    
    func addAdmin(chatId: String, userId: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])
        }
        
        let chatDoc = try await db.collection("chats").document(chatId).getDocument()
        
        // Verificar que el usuario actual es administrador
        guard var adminIds = chatDoc.data()?["adminIds"] as? [String],
              adminIds.contains(currentUserId) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Solo los administradores pueden agregar otros administradores"])
        }
        
        // Verificar que el usuario a agregar es participante del grupo
        guard let participants = chatDoc.data()?["participants"] as? [String],
              participants.contains(userId) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "El usuario debe ser participante del grupo"])
        }
        
        // Verificar que no sea ya administrador
        if adminIds.contains(userId) {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "El usuario ya es administrador"])
        }
        
        // Agregar el nuevo administrador
        adminIds.append(userId)
        
        // Actualizar en Firestore
        try await db.collection("chats").document(chatId).updateData([
            "adminIds": adminIds
        ])
    }
    
    func removeAdmin(chatId: String, userId: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])
        }
        
        let chatDoc = try await db.collection("chats").document(chatId).getDocument()
        
        // Verificar que el usuario actual es el creador del grupo (primer administrador)
        guard let adminIds = chatDoc.data()?["adminIds"] as? [String],
              !adminIds.isEmpty,
              adminIds[0] == currentUserId else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Solo el creador del grupo puede remover administradores"])
        }
        
        // No permitir remover al creador del grupo
        if userId == adminIds[0] {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se puede remover al creador del grupo"])
        }
        
        // No permitir remover al último administrador
        if adminIds.count <= 1 {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Debe haber al menos un administrador en el grupo"])
        }
        
        var updatedAdminIds = adminIds
        // Remover el administrador
        updatedAdminIds.removeAll { $0 == userId }
        
        // Actualizar en Firestore
        try await db.collection("chats").document(chatId).updateData([
            "adminIds": updatedAdminIds
        ])
    }
    
    func addParticipants(chatId: String, newParticipants: [String]) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])
        }
        
        let chatDoc = try await db.collection("chats").document(chatId).getDocument()
        
        // Verificar que el usuario actual es administrador
        guard let adminIds = chatDoc.data()?["adminIds"] as? [String],
              adminIds.contains(currentUserId) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Solo los administradores pueden añadir participantes"])
        }
        
        // Obtener participantes actuales
        guard var participants = chatDoc.data()?["participants"] as? [String] else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error al obtener participantes actuales"])
        }
        
        // Filtrar participantes que ya están en el grupo
        let newValidParticipants = newParticipants.filter { !participants.contains($0) }
        
        if newValidParticipants.isEmpty {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Los usuarios seleccionados ya son participantes del grupo"])
        }
        
        // Añadir nuevos participantes
        participants.append(contentsOf: newValidParticipants)
        
        // Actualizar en Firestore
        try await db.collection("chats").document(chatId).updateData([
            "participants": participants
        ])
        
        // Crear mensaje de sistema informando de los nuevos participantes
        let message = Message(
            id: UUID().uuidString,
            senderId: "system",
            content: "Se han añadido nuevos participantes al grupo",
            timestamp: Date(),
            isRead: false
        )
        
        try await db.collection("chats")
            .document(chatId)
            .collection("messages")
            .document(message.id)
            .setData(message.dictionary)
    }
} 

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct Chat: Identifiable {
    let id: String
    let participants: [String]  // IDs de los usuarios participantes
    let name: String
    let lastMessage: String
    let timeString: String
    let lastMessageTimestamp: Date
    let adminIds: [String]  // Lista de IDs de los administradores
    
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "participants": participants,
            "name": name,
            "lastMessage": lastMessage,
            "lastMessageTimestamp": Timestamp(date: lastMessageTimestamp),
            "adminIds": adminIds
        ]
        
        return dict
    }
}

struct Message: Identifiable, Codable {
    let id: String
    let senderId: String
    let content: String
    let timestamp: Date
    let isRead: Bool
    
    var dictionary: [String: Any] {
        return [
            "senderId": senderId,
            "content": content,
            "timestamp": Timestamp(date: timestamp),
            "isRead": isRead
        ]
    }
}

extension Chat {
    static func fromFirestore(_ document: QueryDocumentSnapshot) -> Chat? {
        let data = document.data()
        
        guard let participants = data["participants"] as? [String],
              let lastMessage = data["lastMessage"] as? String,
              let timestamp = (data["lastMessageTimestamp"] as? Timestamp)?.dateValue(),
              let currentUserId = Auth.auth().currentUser?.uid else {
            return nil
        }
        
        let userNames = data["userNames"] as? [String: String] ?? [:]
        let adminIds = data["adminIds"] as? [String] ?? []
        
        // Si hay un nombre de grupo explícito, usarlo
        var name = data["name"] as? String
        
        // Si no hay nombre de grupo (chat individual), usar el nombre del otro participante
        if name == nil && participants.count == 2 {
            let otherUserId = participants.first { $0 != currentUserId } ?? ""
            name = userNames[otherUserId] ?? "Usuario"
        } else if name == nil {
            name = "Grupo sin nombre"
        }
        
        return Chat(
            id: document.documentID,
            participants: participants,
            name: name!,
            lastMessage: lastMessage,
            timeString: DateFormatter.localizedString(from: timestamp, dateStyle: .none, timeStyle: .short),
            lastMessageTimestamp: timestamp,
            adminIds: adminIds
        )
    }
}

extension Message {
    static func fromFirestore(_ document: QueryDocumentSnapshot) -> Message? {
        let data = document.data()
        
        guard let senderId = data["senderId"] as? String,
              let content = data["content"] as? String,
              let timestamp = (data["timestamp"] as? Timestamp)?.dateValue(),
              let isRead = data["isRead"] as? Bool else {
            return nil
        }
        
        return Message(
            id: document.documentID,
            senderId: senderId,
            content: content,
            timestamp: timestamp,
            isRead: isRead
        )
    }
} 
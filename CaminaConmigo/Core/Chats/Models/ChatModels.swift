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
    
    var dictionary: [String: Any] {
        return [
            "participants": participants,
            "name": name,
            "lastMessage": lastMessage,
            "lastMessageTimestamp": Timestamp(date: lastMessageTimestamp)
        ]
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
              let userNames = data["userNames"] as? [String: String],
              let currentUserId = Auth.auth().currentUser?.uid else {
            return nil
        }
        
        // Obtener el nombre del otro participante
        let otherUserId = participants.first { $0 != currentUserId } ?? ""
        let name = userNames[otherUserId] ?? "Usuario"
        
        return Chat(
            id: document.documentID,
            participants: participants,
            name: name,
            lastMessage: lastMessage,
            timeString: DateFormatter.localizedString(from: timestamp, dateStyle: .none, timeStyle: .short),
            lastMessageTimestamp: timestamp
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
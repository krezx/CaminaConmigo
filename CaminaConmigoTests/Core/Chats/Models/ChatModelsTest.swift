import XCTest
@testable import CaminaConmigo

final class ChatModelsTest: XCTestCase {
    
    func testMessageInitialization() {
        // Given
        let messageId = "test-message-id"
        let senderId = "sender-123"
        let content = "Hola, ¿cómo estás?"
        let timestamp = Date()
        
        // When
        let message = Message(
            id: messageId,
            senderId: senderId,
            content: content,
            timestamp: timestamp,
            isRead: false
        )
        
        // Then
        XCTAssertEqual(message.id, messageId)
        XCTAssertEqual(message.senderId, senderId)
        XCTAssertEqual(message.content, content)
        XCTAssertEqual(message.timestamp, timestamp)
        XCTAssertFalse(message.isRead)
    }
    
    func testChatInitialization() {
        // Given
        let chatId = "test-chat-id"
        let participants = ["user1", "user2"]
        let name = "Test Chat"
        let lastMessage = "Último mensaje"
        let timestamp = Date()
        let adminIds = ["user1"]
        let participantPhotos = ["user1": "photo1.jpg", "user2": "photo2.jpg"]
        
        // When
        let chat = Chat(
            id: chatId,
            participants: participants,
            name: name,
            lastMessage: lastMessage,
            timeString: DateFormatter.localizedString(from: timestamp, dateStyle: .none, timeStyle: .short),
            lastMessageTimestamp: timestamp,
            adminIds: adminIds,
            unreadCount: 0,
            participantPhotos: participantPhotos
        )
        
        // Then
        XCTAssertEqual(chat.id, chatId)
        XCTAssertEqual(chat.participants, participants)
        XCTAssertEqual(chat.name, name)
        XCTAssertEqual(chat.lastMessage, lastMessage)
        XCTAssertEqual(chat.lastMessageTimestamp, timestamp)
        XCTAssertEqual(chat.adminIds, adminIds)
        XCTAssertEqual(chat.participantPhotos, participantPhotos)
    }
    
    func testMessageDictionary() {
        // Given
        let message = Message(
            id: "test-id",
            senderId: "sender-123",
            content: "Test message",
            timestamp: Date(),
            isRead: true
        )
        
        // When
        let dictionary = message.dictionary
        
        // Then
        XCTAssertEqual(dictionary["senderId"] as? String, message.senderId)
        XCTAssertEqual(dictionary["content"] as? String, message.content)
        XCTAssertEqual(dictionary["isRead"] as? Bool, message.isRead)
        XCTAssertNotNil(dictionary["timestamp"])
    }
}

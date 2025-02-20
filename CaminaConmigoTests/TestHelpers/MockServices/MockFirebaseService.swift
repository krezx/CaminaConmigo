import Foundation
@testable import CaminaConmigo

class MockFirebaseService: FirebaseServiceProtocol {
    var mockChats: [Chat] = []
    var mockMessages: [Message] = []
    
    var sendMessageCalled = false
    var createChatCalled = false
    var lastSentMessageText: String?
    var lastChatId: String?
    var lastCreatedChatParticipants: [String]?
    var lastCreatedChatName: String?
    
    func getChats() async throws -> [Chat] {
        return mockChats
    }
    
    func getMessages(for chatId: String) async throws -> [Message] {
        return mockMessages
    }
    
    func sendMessage(chatId: String, text: String) async throws {
        sendMessageCalled = true
        lastSentMessageText = text
        lastChatId = chatId
    }
    
    func createChat(participants: [String], name: String) async throws {
        createChatCalled = true
        lastCreatedChatParticipants = participants
        lastCreatedChatName = name
    }
}

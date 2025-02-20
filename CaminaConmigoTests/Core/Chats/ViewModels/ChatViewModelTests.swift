import XCTest
@testable import CaminaConmigo
import Firebase

final class ChatViewModelTests: XCTestCase {
    var sut: ChatViewModel!
    var mockFirebaseService: MockFirebaseService!
    
    override func setUp() {
        super.setUp()
        mockFirebaseService = MockFirebaseService()
        sut = ChatViewModel(firebaseService: mockFirebaseService)
    }
    
    override func tearDown() {
        sut = nil
        mockFirebaseService = nil
        super.tearDown()
    }
    
    func testLoadChats() async {
        // Given
        let testChat = Chat(
            id: "chat1",
            participants: ["user1", "user2"],
            name: "Test Chat",
            lastMessage: "Hola",
            timeString: "12:00",
            lastMessageTimestamp: Date(),
            adminIds: ["user1"],
            unreadCount: 0,
            participantPhotos: [:]
        )
        mockFirebaseService.mockChats = [testChat]
        
        // When
        await sut.loadChats()
        
        // Then
        XCTAssertEqual(sut.chats.count, 1)
        XCTAssertEqual(sut.chats.first?.id, testChat.id)
    }
    
    func testSendMessage() async {
        // Given
        let chatId = "chat1"
        let messageText = "Hola, ¿cómo estás?"
        
        // When
        await sut.sendMessage(chatId: chatId, text: messageText)
        
        // Then
        XCTAssertTrue(mockFirebaseService.sendMessageCalled)
        XCTAssertEqual(mockFirebaseService.lastSentMessageText, messageText)
        XCTAssertEqual(mockFirebaseService.lastChatId, chatId)
    }
    
    func testLoadMessages() async {
        // Given
        let chatId = "chat1"
        let testMessage = Message(
            id: "msg1",
            senderId: "user1",
            content: "Test message",
            timestamp: Date(),
            isRead: false
        )
        mockFirebaseService.mockMessages = [testMessage]
        
        // When
        await sut.loadMessages(for: chatId)
        
        // Then
        XCTAssertEqual(sut.messages.count, 1)
        XCTAssertEqual(sut.messages.first?.id, testMessage.id)
    }
    
    func testCreateNewChat() async {
        // Given
        let participants = ["user1", "user2"]
        let chatName = "Nuevo Chat"
        
        // When
        await sut.createNewChat(participants: participants, name: chatName)
        
        // Then
        XCTAssertTrue(mockFirebaseService.createChatCalled)
        XCTAssertEqual(mockFirebaseService.lastCreatedChatParticipants, participants)
        XCTAssertEqual(mockFirebaseService.lastCreatedChatName, chatName)
    }
}

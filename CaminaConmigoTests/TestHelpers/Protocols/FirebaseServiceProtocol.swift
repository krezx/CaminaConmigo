import Foundation

protocol FirebaseServiceProtocol {
    func getChats() async throws -> [Chat]
    func getMessages(for chatId: String) async throws -> [Message]
    func sendMessage(chatId: String, text: String) async throws
    func createChat(participants: [String], name: String) async throws
}
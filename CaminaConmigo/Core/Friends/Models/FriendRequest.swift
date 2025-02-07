import Foundation
import FirebaseFirestore

struct FriendRequest: Codable, Identifiable {
    @DocumentID var id: String?
    let fromUserId: String
    let toUserId: String
    let status: RequestStatus
    let createdAt: Date
    let fromUserEmail: String
    let fromUserName: String
    var nickname: String?  // Nickname opcional para el amigo
    
    enum RequestStatus: String, Codable {
        case pending
        case accepted
        case rejected
    }
} 

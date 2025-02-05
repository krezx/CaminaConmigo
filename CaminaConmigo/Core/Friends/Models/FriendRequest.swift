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
    
    enum RequestStatus: String, Codable {
        case pending
        case accepted
        case rejected
    }
} 

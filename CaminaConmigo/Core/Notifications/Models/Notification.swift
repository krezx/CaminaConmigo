import Foundation
import FirebaseFirestore

struct UserNotification: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let type: NotificationType
    let title: String
    let message: String
    let createdAt: Date
    var isRead: Bool
    let data: [String: String]
    
    enum NotificationType: String, Codable {
        case friendRequest = "friendRequest"
        case friendRequestAccepted = "friendRequestAccepted"
        case friendReport = "friendReport"
        case newReport = "newReport"
        case reportComment = "reportComment"
        case groupInvite = "groupInvite"
    }
    
    mutating func markAsRead() {
        isRead = true
    }
    
    static func createFriendRequestAcceptedNotification(
        forUser userId: String,
        fromUser: UserProfile
    ) -> UserNotification {
        UserNotification(
            userId: userId,
            type: .friendRequestAccepted,
            title: "Solicitud aceptada",
            message: "\(fromUser.username) ha aceptado tu solicitud de amistad",
            createdAt: Date(),
            isRead: false,
            data: [
                "fromUserId": fromUser.id,
                "fromUsername": fromUser.username
            ]
        )
    }
} 

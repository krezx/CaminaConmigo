import Foundation

struct UserProfile: Codable {
    var id: String
    var name: String
    var username: String
    var profileType: String
    var joinDate: Date
    var photoURL: String?
    
    init(id: String, name: String = "", username: String = "", profileType: String = "Público", photoURL: String? = nil) {
        self.id = id
        self.name = name
        self.username = username
        self.profileType = profileType
        self.joinDate = Date()
        self.photoURL = photoURL
    }
} 

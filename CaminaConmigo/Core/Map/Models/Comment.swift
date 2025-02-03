import Foundation
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    var id: String?
    let text: String
    let authorId: String
    let authorName: String
    let reportId: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case authorId
        case authorName
        case reportId
        case timestamp
    }
    
    init(id: String? = nil, text: String, authorId: String, authorName: String, reportId: String, timestamp: Date) {
        self.id = id
        self.text = text
        self.authorId = authorId
        self.authorName = authorName
        self.reportId = reportId
        self.timestamp = timestamp
    }
} 

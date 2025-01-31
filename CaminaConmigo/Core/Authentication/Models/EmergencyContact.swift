import Foundation

struct EmergencyContact: Identifiable, Codable {
    var id: String
    let name: String
    let phone: String
    var order: Int
    
    init(id: String = UUID().uuidString, name: String, phone: String, order: Int) {
        self.id = id
        self.name = name
        self.phone = phone
        self.order = order
    }
} 
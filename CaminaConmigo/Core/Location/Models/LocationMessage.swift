import Foundation
import CoreLocation
import FirebaseFirestore

struct LocationMessage: Codable, Identifiable {
    let id: String
    let senderId: String
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let isActive: Bool
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var dictionary: [String: Any] {
        return [
            "senderId": senderId,
            "timestamp": Timestamp(date: timestamp),
            "latitude": latitude,
            "longitude": longitude,
            "isActive": isActive
        ]
    }
    
    static func fromFirestore(_ document: QueryDocumentSnapshot) -> LocationMessage? {
        let data = document.data()
        
        guard let senderId = data["senderId"] as? String,
              let timestamp = (data["timestamp"] as? Timestamp)?.dateValue(),
              let latitude = data["latitude"] as? Double,
              let longitude = data["longitude"] as? Double,
              let isActive = data["isActive"] as? Bool else {
            return nil
        }
        
        return LocationMessage(
            id: document.documentID,
            senderId: senderId,
            timestamp: timestamp,
            latitude: latitude,
            longitude: longitude,
            isActive: isActive
        )
    }
} 
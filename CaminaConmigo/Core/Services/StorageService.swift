import Foundation
import FirebaseStorage
import UIKit

class StorageService {
    private let storage = Storage.storage().reference()
    
    func uploadLogo() async throws -> String {
        guard let image = UIImage(named: "logo1"),
              let imageData = image.pngData() else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error al preparar la imagen"])
        }
        
        let logoRef = storage.child("assets/logo1.png")
        
        _ = try await logoRef.putDataAsync(imageData, metadata: nil)
        let downloadURL = try await logoRef.downloadURL()
        
        return downloadURL.absoluteString
    }
} 
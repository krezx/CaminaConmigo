import Foundation
@testable import CaminaConmigo

class MockFirebaseService {
    var shouldSucceed = true
    var error: Error?
    var mockData: [String: Any] = [:]
    
    func reset() {
        shouldSucceed = true
        error = nil
        mockData = [:]
    }
}

import XCTest
@testable import CaminaConmigo

class AuthenticationViewModelTests: XCTestCase {
    var sut: AuthenticationViewModel!
    var mockFirebaseService: MockFirebaseService!
    
    override func setUp() {
        super.setUp()
        mockFirebaseService = MockFirebaseService()
        sut = AuthenticationViewModel()
        // Inyectar el mock service
    }
    
    override func tearDown() {
        sut = nil
        mockFirebaseService = nil
        super.tearDown()
    }
    
    func testSignInWithGoogle_Success() async {
        // Arrange
        mockFirebaseService.shouldSucceed = true
        
        // Act
        do {
            try await sut.signInWithGoogle()
            
            // Assert
            XCTAssertNotNil(sut.userSession)
        } catch {
            XCTFail("No debería lanzar error: \(error)")
        }
    }
    
    func testSignInWithGoogle_Failure() async {
        // Arrange
        mockFirebaseService.shouldSucceed = false
        mockFirebaseService.error = NSError(domain: "", code: -1)
        
        // Act & Assert
        do {
            try await sut.signInWithGoogle()
            XCTFail("Debería haber lanzado un error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}

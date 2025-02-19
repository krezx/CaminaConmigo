import XCTest
@testable import CaminaConmigo

class ProfileViewModelTests: XCTestCase {
    var sut: ProfileViewModel!
    var mockFirebaseService: MockFirebaseService!
    
    override func setUp() {
        super.setUp()
        mockFirebaseService = MockFirebaseService()
        sut = ProfileViewModel()
    }
    
    override func tearDown() {
        sut = nil
        mockFirebaseService = nil
        super.tearDown()
    }
    
    func testIsUsernameValid_WithValidUsername_ReturnsTrue() {
        // Arrange
        let username = "usuario123"
        
        // Act
        let result = sut.isUsernameValid(username)
        
        // Assert
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.message, "")
    }
    
    func testIsUsernameValid_WithSpaces_ReturnsFalse() {
        // Arrange
        let username = "usuario 123"
        
        // Act
        let result = sut.isUsernameValid(username)
        
        // Assert
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.message, "El nombre de usuario no puede contener espacios")
    }
    
    func testIsUsernameValid_WithShortUsername_ReturnsFalse() {
        // Arrange
        let username = "us"
        
        // Act
        let result = sut.isUsernameValid(username)
        
        // Assert
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.message, "El nombre de usuario debe tener al menos 3 caracteres")
    }
    
    func testUpdateProfileType_UpdatesProfileTypeCorrectly() {
        // Arrange
        let newProfileType = "Privado"
        let userProfile = UserProfile(id: "testId", name: "Test User", username: "testuser", email: "test@test.com")
        sut.userProfile = userProfile
        
        // Act
        sut.updateProfileType(newProfileType)
        
        // Assert
        XCTAssertEqual(sut.userProfile?.profileType, newProfileType)
    }
    
    func testRemoveProfilePhoto_RemovesPhotoURL() {
        // Arrange
        let userProfile = UserProfile(id: "testId", name: "Test User", username: "testuser", email: "test@test.com", photoURL: "test-url")
        sut.userProfile = userProfile
        
        // Act
        sut.removeProfilePhoto()
        
        // Assert
        XCTAssertNil(sut.userProfile?.photoURL)
    }
}

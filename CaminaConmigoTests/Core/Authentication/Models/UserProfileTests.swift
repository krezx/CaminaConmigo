import XCTest
@testable import CaminaConmigo

class UserProfileTests: XCTestCase {
    
    func testUserProfileInitialization() {
        // Arrange
        let id = "testId"
        let name = "Test User"
        let username = "testuser"
        let email = "test@test.com"
        let profileType = "Privado"
        let photoURL = "https://example.com/photo.jpg"
        
        // Act
        let profile = UserProfile(
            id: id,
            name: name,
            username: username,
            email: email,
            profileType: profileType,
            photoURL: photoURL
        )
        
        // Assert
        XCTAssertEqual(profile.id, id)
        XCTAssertEqual(profile.name, name)
        XCTAssertEqual(profile.username, username)
        XCTAssertEqual(profile.email, email)
        XCTAssertEqual(profile.profileType, profileType)
        XCTAssertEqual(profile.photoURL, photoURL)
    }
    
    func testUserProfileDefaultValues() {
        // Arrange & Act
        let profile = UserProfile(id: "testId")
        
        // Assert
        XCTAssertEqual(profile.id, "testId")
        XCTAssertEqual(profile.name, "")
        XCTAssertEqual(profile.username, "")
        XCTAssertEqual(profile.email, "")
        XCTAssertEqual(profile.profileType, "Público")
        XCTAssertNil(profile.photoURL)
        XCTAssertNotNil(profile.joinDate)
    }
    
    func testUserProfileJoinDateInitialization() {
        // Arrange
        let beforeDate = Date()
        
        // Act
        let profile = UserProfile(id: "testId")
        let afterDate = Date()
        
        // Assert
        XCTAssertNotNil(profile.joinDate)
        XCTAssertLessThanOrEqual(beforeDate, profile.joinDate)
        XCTAssertGreaterThanOrEqual(afterDate, profile.joinDate)
    }
    
    func testUserProfileOptionalPhotoURL() {
        // Arrange & Act
        let profileWithPhoto = UserProfile(id: "testId", photoURL: "https://example.com/photo.jpg")
        let profileWithoutPhoto = UserProfile(id: "testId")
        
        // Assert
        XCTAssertNotNil(profileWithPhoto.photoURL)
        XCTAssertNil(profileWithoutPhoto.photoURL)
    }
}

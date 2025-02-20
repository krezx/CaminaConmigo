import XCTest
@testable import CaminaConmigo

class EmergencyContactTests: XCTestCase {
    
    func testEmergencyContactInitialization() {
        // Arrange
        let id = "testId"
        let name = "Juan Pérez"
        let phone = "+56912345678"
        let order = 1
        
        // Act
        let contact = EmergencyContact(id: id, name: name, phone: phone, order: order)
        
        // Assert
        XCTAssertEqual(contact.id, id)
        XCTAssertEqual(contact.name, name)
        XCTAssertEqual(contact.phone, phone)
        XCTAssertEqual(contact.order, order)
    }
    
    func testEmergencyContactDefaultIdGeneration() {
        // Arrange
        let name = "María González"
        let phone = "+56987654321"
        let order = 0
        
        // Act
        let contact = EmergencyContact(name: name, phone: phone, order: order)
        
        // Assert
        XCTAssertFalse(contact.id.isEmpty)
        XCTAssertEqual(contact.name, name)
        XCTAssertEqual(contact.phone, phone)
        XCTAssertEqual(contact.order, order)
    }
    
    func testEmergencyContactCodable() throws {
        // Arrange
        let contact = EmergencyContact(
            id: "testId",
            name: "Pedro Sánchez",
            phone: "+56923456789",
            order: 2
        )
        
        // Act - Codificar
        let encoder = JSONEncoder()
        let data = try encoder.encode(contact)
        
        // Act - Decodificar
        let decoder = JSONDecoder()
        let decodedContact = try decoder.decode(EmergencyContact.self, from: data)
        
        // Assert
        XCTAssertEqual(contact.id, decodedContact.id)
        XCTAssertEqual(contact.name, decodedContact.name)
        XCTAssertEqual(contact.phone, decodedContact.phone)
        XCTAssertEqual(contact.order, decodedContact.order)
    }
}

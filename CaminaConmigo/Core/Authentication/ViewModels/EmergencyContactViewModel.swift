import Foundation
import FirebaseFirestore
import FirebaseAuth

class EmergencyContactViewModel: ObservableObject {
    @Published var contacts: [EmergencyContact] = []
    @Published var error: String?
    private let db = Firestore.firestore()
    
    init() {
        loadContacts()
    }
    
    func loadContacts() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId)
            .collection("emergency_contacts")
            .order(by: "order")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    self?.error = error.localizedDescription
                    return
                }
                
                self?.contacts = snapshot?.documents.compactMap { document -> EmergencyContact? in
                    let data = document.data()
                    return EmergencyContact(
                        id: document.documentID,
                        name: data["name"] as? String ?? "",
                        phone: data["phone"] as? String ?? "",
                        order: data["order"] as? Int ?? 0
                    )
                } ?? []
            }
    }
    
    func addContact(name: String, phone: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let newContact = EmergencyContact(
            name: name,
            phone: phone,
            order: contacts.count
        )
        
        let data: [String: Any] = [
            "name": newContact.name,
            "phone": newContact.phone,
            "order": newContact.order
        ]
        
        db.collection("users").document(userId)
            .collection("emergency_contacts")
            .addDocument(data: data) { [weak self] error in
                if let error = error {
                    self?.error = error.localizedDescription
                }
            }
    }
    
    func updateContactsOrder() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let batch = db.batch()
        
        for (index, contact) in contacts.enumerated() {
            let docRef = db.collection("users").document(userId)
                .collection("emergency_contacts")
                .document(contact.id)
            
            batch.updateData(["order": index], forDocument: docRef)
        }
        
        batch.commit { [weak self] error in
            if let error = error {
                self?.error = error.localizedDescription
            }
        }
    }
    
    func updateContact(id: String, name: String, phone: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = [
            "name": name,
            "phone": phone
        ]
        
        db.collection("users").document(userId)
            .collection("emergency_contacts")
            .document(id)
            .updateData(data) { [weak self] error in
                if let error = error {
                    self?.error = error.localizedDescription
                }
            }
    }
} 
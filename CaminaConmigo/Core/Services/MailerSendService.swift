import Foundation

class MailerSendService {
    private let apiKey = "mlsn.26eeb53c2e58beecca0eea8dfd0a25fabb71990ced628d5f37472a5d61ce1830"
    private let baseURL = "https://api.mailersend.com/v1/email"
    
    func sendSuggestion(nombre: String, numero: String, razon: String, mensaje: String, isAnonymous: Bool) async throws {
        let emailData: [String: Any] = [
            "from": [
                "email": "sugerencias@trial-zr6ke4n3k53lon12.mlsender.net",
                "name": "Sistema de Sugerencias"
            ],
            "to": [
                [
                    "email": "camina.conmigo4r@gmail.com",
                    "name": "Administrador"
                ]
            ],
            "subject": "Nueva Sugerencia: \(razon)",
            "text": """
                Nombre: \(isAnonymous ? "Anónimo" : nombre)
                Número: \(isAnonymous ? "No proporcionado" : numero)
                Razón: \(razon)
                
                Mensaje:
                \(mensaje)
                """
        ]
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: emailData)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error al enviar el correo"])
        }
    }
} 
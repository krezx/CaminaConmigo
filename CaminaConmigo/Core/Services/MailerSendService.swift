import Foundation

class MailerSendService {
    private let apiKey = "mlsn.26eeb53c2e58beecca0eea8dfd0a25fabb71990ced628d5f37472a5d61ce1830"
    private let baseURL = "https://api.mailersend.com/v1/email"
    private let storageService = StorageService()
    private var logoURL: String?
    
    init() {
        // Cargar el logo al inicializar el servicio
        Task {
            do {
                self.logoURL = try await storageService.uploadLogo()
            } catch {
                print("Error al cargar el logo: \(error)")
            }
        }
    }
    
    func sendSuggestion(nombre: String, numero: String, razon: String, mensaje: String, isAnonymous: Bool) async throws {
        let htmlContent = """
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body {
                        font-family: Arial, sans-serif;
                        line-height: 1.6;
                        color: #333;
                        max-width: 400px;
                        margin: 0 auto;
                        padding: 15px;
                    }
                    .header {
                        text-align: center;
                        margin-bottom: 20px;
                        background-color: #f9f9f9;
                        padding: 15px;
                        border-radius: 8px;
                    }
                    .logo {
                        max-width: 150px;
                        height: auto;
                        margin-bottom: 15px;
                    }
                    .content {
                        background-color: #f9f9f9;
                        padding: 15px;
                        border-radius: 8px;
                    }
                    .field {
                        margin-bottom: 12px;
                    }
                    .label {
                        font-weight: bold;
                        color: #EF6098;
                    }
                    .message-box {
                        background-color: white;
                        padding: 12px;
                        border-radius: 5px;
                        margin-top: 8px;
                    }
                    .title {
                        color: #EF6098;
                        margin-top: 15px;
                        font-size: 1.5em;
                    }
                </style>
            </head>
            <body>
                <div class="header">
                    \(logoURL != nil ? "<img src='\(logoURL!)' alt='CaminaConmigo Logo' class='logo'>" : "")
                    <h2 class="title">Nueva Sugerencia Recibida</h2>
                </div>
                <div class="content">
                    <div class="field">
                        <span class="label">Nombre:</span> 
                        <span>\(isAnonymous ? "Anónimo" : nombre)</span>
                    </div>
                    <div class="field">
                        <span class="label">Número:</span>
                        <span>\(isAnonymous ? "No proporcionado" : numero)</span>
                    </div>
                    <div class="field">
                        <span class="label">Razón:</span>
                        <span>\(razon)</span>
                    </div>
                    <div class="field">
                        <span class="label">Mensaje:</span>
                        <div class="message-box">
                            \(mensaje.replacingOccurrences(of: "\n", with: "<br>"))
                        </div>
                    </div>
                </div>
            </body>
            </html>
            """

        let emailData: [String: Any] = [
            "from": [
                "email": "sugerencias@trial-zr6ke4n3k53lon12.mlsender.net",
                "name": "Sistema de Sugerencias - CaminaConmigo"
            ],
            "to": [
                [
                    "email": "camina.conmigo4r@gmail.com",
                    "name": "Administrador"
                ]
            ],
            "subject": "Nueva Sugerencia: \(razon)",
            "html": htmlContent
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
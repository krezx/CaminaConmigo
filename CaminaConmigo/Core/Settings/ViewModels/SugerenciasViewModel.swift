import Foundation

@MainActor
class SugerenciasViewModel: ObservableObject {
    @Published var nombre: String = ""
    @Published var numero: String = ""
    @Published var razon: String = ""
    @Published var mensaje: String = ""
    @Published var enviarAnonimo: Bool = false
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    private let mailerService = MailerSendService()
    
    func validarFormulario() -> Bool {
        // Si es anónimo, solo validamos razón y mensaje
        if enviarAnonimo {
            if razon.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
               mensaje.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                alertMessage = "Por favor, complete la razón y el mensaje"
                showAlert = true
                return false
            }
            return true
        }
        
        // Si no es anónimo, validamos todos los campos
        if nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           numero.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           razon.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           mensaje.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Por favor, complete todos los campos"
            showAlert = true
            return false
        }
        
        return true
    }
    
    func enviarSugerencia() async {
        if !validarFormulario() { return }
        
        isLoading = true
        do {
            try await mailerService.sendSuggestion(
                nombre: nombre,
                numero: numero,
                razon: razon,
                mensaje: mensaje,
                isAnonymous: enviarAnonimo
            )
            alertMessage = "Sugerencia enviada con éxito"
            showAlert = true
        } catch {
            alertMessage = "Error al enviar la sugerencia: \(error.localizedDescription)"
            showAlert = true
        }
        isLoading = false
    }
} 
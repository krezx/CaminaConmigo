import SwiftUI

class MapViewModel: ObservableObject {
    @Published var showReportSheet = false
    @Published var showReportDetailSheet = false
    @Published var currentReport: Report?
    
    let reportTypes = [
        ReportType(title: "Agresión Verbal", imageName: "agresion_verbal"),
        ReportType(title: "Agresión Sexual", imageName: "agresion_sexual"),
        ReportType(title: "Agresión Física", imageName: "agresion_fisica"),
        ReportType(title: "Reunión de hombres", imageName: "reunion_hombres"),
        ReportType(title: "Personas en situación de calle", imageName: "persona_situacion_calle"),
        ReportType(title: "Falta de Baños Públicos", imageName: "falta_baños"),
        ReportType(title: "Presencia de Bares y Restobares", imageName: "bares"),
        ReportType(title: "Mobiliario Inadecuado", imageName: "mobiliario_inadecuado"),
        ReportType(title: "Veredas en mal estado", imageName: "veredas_malas"),
        ReportType(title: "Poca Iluminación", imageName: "mala_iluminacion"),
        ReportType(title: "Espacios Abandonados", imageName: "espacios_abandonados"),
        ReportType(title: "Puntos Ciegos", imageName: "puntos_ciegos"),
        ReportType(title: "Vegetación Abundante", imageName: "vegetacion_abundante")
    ]
    
    func handleReport(type: ReportType) {
        currentReport = Report(type: type, description: "", location: "")
        showReportSheet = false
        showReportDetailSheet = true
    }
    
    func submitReport() {
        guard let report = currentReport else { return }
        // Aquí irá la lógica para enviar el reporte al servidor
        print("Enviando reporte: \(report)")
        showReportDetailSheet = false
        currentReport = nil
    }
} 

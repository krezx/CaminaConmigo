//
//  ReportViewModel.swift
//  CaminaConmigo
//
//  Created by a on 28-01-25.
//

import SwiftUI

/// ViewModel para gestionar la lógica de los reportes.
class ReportViewModel: ObservableObject {
    @Published var showReportSheet = false  // Controla la visibilidad de la hoja de reporte.
    @Published var showReportDetailSheet = false  // Controla la visibilidad de la hoja de detalles del reporte.
    @Published var currentReport: Report?  // El reporte actualmente seleccionado para ser procesado.

    // Lista de tipos de reportes disponibles para el usuario.
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
    
    /// Maneja el evento cuando un usuario selecciona un tipo de reporte.
    /// - Parameter type: El tipo de reporte seleccionado.
    func handleReport(type: ReportType) {
        currentReport = Report(type: type, description: "", location: "")
        showReportSheet = false  // Cierra la hoja de selección de reporte.
        showReportDetailSheet = true  // Muestra la hoja de detalles del reporte.
    }
    
    /// Envía el reporte al servidor o sistema de backend.
    func submitReport() {
        guard let report = currentReport else { return }
        // Aquí irá la lógica para enviar el reporte al servidor.
        print("Enviando reporte: \(report)")
        showReportDetailSheet = false  // Cierra la hoja de detalles del reporte después de enviarlo.
        currentReport = nil  // Resetea el reporte actual después de enviarlo.
    }
}

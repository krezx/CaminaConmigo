//
//  ReportViewModel.swift
//  CaminaConmigo
//
//  Created by a on 28-01-25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import CoreLocation

/// ViewModel para gestionar la lógica de los reportes.
class ReportViewModel: ObservableObject {
    @Published var showReportSheet = false  // Controla la visibilidad de la hoja de reporte.
    @Published var showReportDetailSheet = false  // Controla la visibilidad de la hoja de detalles del reporte.
    @Published var currentReport: Report?  // El reporte actualmente seleccionado para ser procesado.
    @Published var selectedLocation: CLLocationCoordinate2D?

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

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
        currentReport = Report(type: type, description: "", location: "", isAnonymous: true)
        showReportSheet = false  // Cierra la hoja de selección de reporte.
        showReportDetailSheet = true  // Muestra la hoja de detalles del reporte.
    }
    
    /// Envía el reporte al servidor o sistema de backend.
    func submitReport(image: UIImage?) {
        guard let report = currentReport else { return }

        let reportData: [String: Any] = [
            "type": report.type.title,
            "description": report.description,
            "location": report.location,
            "isAnonymous": report.isAnonymous,
            "timestamp": Timestamp(date: Date()),
            "latitude": selectedLocation?.latitude ?? 0,
            "longitude": selectedLocation?.longitude ?? 0
        ]

        if let image = image {
            uploadImage(image) { url in
                var data = reportData
                data["imageUrl"] = url?.absoluteString ?? ""
                self.saveReportData(data)
            }
        } else {
            saveReportData(reportData)
        }
    }

    private func uploadImage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        let imageData = image.jpegData(compressionQuality: 0.8)
        let storageRef = storage.reference().child("report_images/\(UUID().uuidString).jpg")
        storageRef.putData(imageData!, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url)
            }
        }
    }

    private func saveReportData(_ data: [String: Any]) {
        db.collection("reportes").addDocument(data: data) { error in
            if let error = error {
                print("Error saving report: \(error.localizedDescription)")
            } else {
                print("Report saved successfully")
            }
        }
        showReportDetailSheet = false
        currentReport = nil
    }
}
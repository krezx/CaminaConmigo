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
    @Published var reports: [ReportAnnotation] = []
    @Published var comments: [Comment] = []
    @Published var isLoadingComments = false

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
    
    init() {
        fetchReports()
    }
    
    func fetchReports() {
        db.collection("reportes").addSnapshotListener { [weak self] querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching reports: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self?.reports = documents.compactMap { document in
                let data = document.data()
                guard let latitude = data["latitude"] as? Double,
                      let longitude = data["longitude"] as? Double,
                      let typeTitle = data["type"] as? String,
                      let description = data["description"] as? String,
                      let type = self?.reportTypes.first(where: { $0.title == typeTitle }) else {
                    return nil
                }
                
                let likes = data["likes"] as? Int ?? 0
                
                let report = Report(
                    id: document.documentID,
                    type: type,
                    description: description,
                    coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    likes: likes
                )
                
                return ReportAnnotation(report: report)
            }
        }
    }
    
    /// Maneja el evento cuando un usuario selecciona un tipo de reporte.
    /// - Parameter type: El tipo de reporte seleccionado.
    func handleReport(type: ReportType) {
        currentReport = Report(type: type, description: "")
        showReportSheet = false
        showReportDetailSheet = true
    }
    
    /// Envía el reporte al servidor o sistema de backend.
    func submitReport(image: UIImage?) {
        guard let report = currentReport else { return }
        guard let coordinate = selectedLocation else { return }

        // Actualizar las coordenadas del reporte actual
        currentReport?.coordinate = coordinate

        let reportData: [String: Any] = [
            "type": report.type.title,
            "description": report.description,
            "isAnonymous": report.isAnonymous,
            "timestamp": Timestamp(date: Date()),
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "likes": 0
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
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        let storageRef = storage.reference().child("report_images/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
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

    /// Obtiene los comentarios para un reporte específico
    func fetchComments(for reportId: String) {
        isLoadingComments = true
        db.collection("reportes").document(reportId)
            .collection("comentarios")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching comments: \(error.localizedDescription)")
                    self.isLoadingComments = false
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    self.comments = []
                    self.isLoadingComments = false
                    return
                }
                
                self.comments = documents.compactMap { document in
                    let data = document.data()
                    guard let text = data["text"] as? String,
                          let authorId = data["authorId"] as? String,
                          let authorName = data["authorName"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp else {
                        return nil
                    }
                    
                    return Comment(
                        id: document.documentID,
                        text: text,
                        authorId: authorId,
                        authorName: authorName,
                        reportId: reportId,
                        timestamp: timestamp.dateValue()
                    )
                }
                self.isLoadingComments = false
            }
    }
    
    /// Agrega un nuevo comentario a un reporte
    func addComment(text: String, reportId: String, authorId: String, authorName: String) {
        let commentData: [String: Any] = [
            "text": text,
            "authorId": authorId,
            "authorName": authorName,
            "reportId": reportId,
            "timestamp": Timestamp(date: Date())
        ]
        
        db.collection("reportes").document(reportId)
            .collection("comentarios")
            .addDocument(data: commentData) { [weak self] error in
                if let error = error {
                    print("Error adding comment: \(error.localizedDescription)")
                }
            }
    }
    
    /// Elimina un comentario específico
    func deleteComment(commentId: String, reportId: String) {
        db.collection("reportes").document(reportId)
            .collection("comentarios")
            .document(commentId)
            .delete { [weak self] error in
                if let error = error {
                    print("Error deleting comment: \(error.localizedDescription)")
                }
            }
    }
    
    /// Maneja el like de un reporte
    func toggleLike(for reportId: String, userId: String) {
        let reportRef = db.collection("reportes").document(reportId)
        let likesRef = reportRef.collection("likes")
        
        likesRef.document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error checking like status: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot, snapshot.exists {
                // Si ya existe un like, lo removemos
                likesRef.document(userId).delete()
                reportRef.updateData(["likes": FieldValue.increment(Int64(-1))])
            } else {
                // Si no existe un like, lo añadimos
                likesRef.document(userId).setData(["timestamp": Timestamp(date: Date())])
                reportRef.updateData(["likes": FieldValue.increment(Int64(1))])
            }
        }
    }
    
    /// Verifica si un usuario ha dado like a un reporte
    func checkLikeStatus(for reportId: String, userId: String, completion: @escaping (Bool) -> Void) {
        db.collection("reportes").document(reportId)
            .collection("likes")
            .document(userId)
            .getDocument { snapshot, error in
                if let error = error {
                    print("Error checking like status: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                completion(snapshot?.exists ?? false)
            }
    }
}
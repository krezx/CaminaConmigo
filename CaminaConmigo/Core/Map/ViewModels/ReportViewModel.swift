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
import FirebaseAuth

/// ViewModel para gestionar la lógica de los reportes.
class ReportViewModel: ObservableObject {
    @Published var showReportSheet = false  // Controla la visibilidad de la hoja de reporte.
    @Published var showReportDetailSheet = false  // Controla la visibilidad de la hoja de detalles del reporte.
    @Published var currentReport: Report?  // El reporte actualmente seleccionado para ser procesado.
    @Published var selectedLocation: CLLocationCoordinate2D?
    @Published var reports: [ReportAnnotation] = []
    @Published var comments: [Comment] = []
    @Published var isLoadingComments = false
    @Published var filteredReports: [ReportAnnotation] = []
    @Published var selectedFilter: String = "Tendencias"

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
        db.collection("reportes").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching reports: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.reports = documents.compactMap { document in
                let data = document.data()
                guard let latitude = data["latitude"] as? Double,
                      let longitude = data["longitude"] as? Double,
                      let typeTitle = data["type"] as? String,
                      let description = data["description"] as? String,
                      let timestamp = data["timestamp"] as? Timestamp,
                      let userId = data["userId"] as? String,
                      let type = self.reportTypes.first(where: { $0.title == typeTitle }) else {
                    return nil
                }
                
                let likes = data["likes"] as? Int ?? 0
                
                let report = Report(
                    id: document.documentID,
                    type: type,
                    description: description,
                    coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    likes: likes,
                    timestamp: timestamp.dateValue(),
                    userId: userId
                )
                
                return ReportAnnotation(report: report)
            }
            
            // Aplicar el filtro actual después de obtener los reportes
            self.filterReports(by: self.selectedFilter)
        }
    }
    
    /// Maneja el evento cuando un usuario selecciona un tipo de reporte.
    /// - Parameter type: El tipo de reporte seleccionado.
    func handleReport(type: ReportType) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        currentReport = Report(
            type: type, 
            description: "",
            userId: currentUserId
        )
        showReportSheet = false
        showReportDetailSheet = true
    }
    
    /// Envía el reporte al servidor o sistema de backend.
    func submitReport(image: UIImage?) {
        guard let report = currentReport else { return }
        guard let coordinate = selectedLocation else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        // Actualizar las coordenadas del reporte actual
        currentReport?.coordinate = coordinate

        let reportData: [String: Any] = [
            "type": report.type.title,
            "description": report.description,
            "isAnonymous": report.isAnonymous,
            "timestamp": Timestamp(date: Date()),
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "likes": 0,
            "userId": currentUserId
        ]

        if let image = image {
            uploadImage(image) { url in
                var data = reportData
                data["imageUrl"] = url?.absoluteString ?? ""
                self.saveReportData(data) { reportId in
                    if !report.isAnonymous {
                        self.notifyFriends(reportId: reportId, report: report)
                    }
                }
            }
        } else {
            saveReportData(reportData) { reportId in
                if !report.isAnonymous {
                    self.notifyFriends(reportId: reportId, report: report)
                }
            }
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

    private func saveReportData(_ data: [String: Any], completion: @escaping (String) -> Void) {
        let docRef = db.collection("reportes").addDocument(data: data) { [weak self] error in
            if let error = error {
                print("Error saving report: \(error.localizedDescription)")
            }
            self?.showReportDetailSheet = false
            self?.currentReport = nil
        }
        completion(docRef.documentID)
    }

    private func notifyFriends(reportId: String, report: Report) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        // Obtener el nombre del usuario actual
        db.collection("users").document(currentUserId).getDocument { [weak self] snapshot, error in
            guard let self = self,
                  let userData = snapshot?.data(),
                  let username = userData["username"] as? String else { return }
            
            // Obtener la lista de amigos
            self.db.collection("users").document(currentUserId)
                .collection("friends")
                .getDocuments { snapshot, error in
                    guard let documents = snapshot?.documents else { return }
                    
                    // Para cada amigo, crear una notificación
                    for doc in documents {
                        let friendId = doc.documentID
                        
                        let notification = UserNotification(
                            userId: friendId,
                            type: .friendReport,
                            title: "Nuevo reporte de amigo",
                            message: "\(username) ha reportado un incidente de \(report.type.title)",
                            createdAt: Date(),
                            isRead: false,
                            data: [
                                "reportId": reportId,
                                "reportType": report.type.title,
                                "friendId": currentUserId,
                                "friendName": username
                            ]
                        )
                        
                        // Guardar la notificación en Firestore
                        try? self.db.collection("users")
                            .document(friendId)
                            .collection("notifications")
                            .document()
                            .setData(from: notification)
                    }
                }
        }
    }

    /// Obtiene los comentarios para un reporte específico
    func fetchComments(for reportId: String) {
        isLoadingComments = true
        db.collection("reportes").document(reportId)
            .collection("comentarios")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { querySnapshot, error in
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
        // Primero obtenemos el reporte para saber quién es el autor
        db.collection("reportes").document(reportId).getDocument { [weak self] document, error in
            guard let self = self,
                  let reportData = document?.data(),
                  let reportAuthorId = reportData["userId"] as? String,
                  // No enviamos notificación si el autor del comentario es el mismo que el del reporte
                  reportAuthorId != authorId else {
                return
            }
            
            // Crear el comentario
            let commentData: [String: Any] = [
                "text": text,
                "authorId": authorId,
                "authorName": authorName,
                "reportId": reportId,
                "timestamp": Timestamp(date: Date())
            ]
            
            // Guardar el comentario
            self.db.collection("reportes").document(reportId)
                .collection("comentarios")
                .addDocument(data: commentData) { error in
                    if let error = error {
                        print("Error adding comment: \(error.localizedDescription)")
                        return
                    }
                    
                    // Crear la notificación para el autor del reporte
                    let notification = UserNotification(
                        userId: reportAuthorId,
                        type: .reportComment,
                        title: "Nuevo comentario",
                        message: "\(authorName) comentó en tu reporte: \(text)",
                        createdAt: Date(),
                        isRead: false,
                        data: [
                            "reportId": reportId,
                            "commentAuthorId": authorId,
                            "commentAuthorName": authorName,
                            "commentText": text
                        ]
                    )
                    
                    // Guardar la notificación
                    self.db.collection("users")
                        .document(reportAuthorId)
                        .collection("notifications")
                        .document()
                        .setData(try! Firestore.Encoder().encode(notification))
                }
        }
    }
    
    /// Elimina un comentario específico
    func deleteComment(commentId: String, reportId: String) {
        // Primero obtenemos el comentario para tener la información necesaria
        db.collection("reportes").document(reportId)
            .collection("comentarios")
            .document(commentId)
            .getDocument { [weak self] snapshot, error in
                guard let self = self,
                      let commentData = snapshot?.data(),
                      let authorId = commentData["authorId"] as? String else {
                    return
                }
                
                // Obtenemos el ID del autor del reporte
                self.db.collection("reportes").document(reportId).getDocument { document, error in
                    guard let reportData = document?.data(),
                          let reportAuthorId = reportData["userId"] as? String else {
                        return
                    }
                    
                    // Solo buscamos la notificación si el autor del comentario es diferente al autor del reporte
                    if authorId != reportAuthorId {
                        // Buscamos la notificación relacionada con este comentario
                        self.db.collection("users")
                            .document(reportAuthorId)
                            .collection("notifications")
                            .whereField("data.reportId", isEqualTo: reportId)
                            .whereField("data.commentAuthorId", isEqualTo: authorId)
                            .whereField("type", isEqualTo: "reportComment")
                            .getDocuments { snapshot, error in
                                if let documents = snapshot?.documents {
                                    // Eliminamos todas las notificaciones encontradas
                                    let batch = self.db.batch()
                                    for doc in documents {
                                        batch.deleteDocument(doc.reference)
                                    }
                                    batch.commit()
                                }
                            }
                    }
                    
                    // Eliminamos el comentario
                    self.db.collection("reportes").document(reportId)
                        .collection("comentarios")
                        .document(commentId)
                        .delete { error in
                            if let error = error {
                                print("Error deleting comment: \(error.localizedDescription)")
                            }
                        }
                }
            }
    }
    
    /// Maneja el like de un reporte
    func toggleLike(for reportId: String, userId: String) {
        let reportRef = db.collection("reportes").document(reportId)
        let likesRef = reportRef.collection("likes")
        
        likesRef.document(userId).getDocument { snapshot, error in
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

    func filterReports(by filter: String) {
        switch filter {
        case "Tendencias":
            filteredReports = reports.sorted { $0.report.likes > $1.report.likes }
        case "Recientes":
            filteredReports = reports.sorted { $0.report.timestamp > $1.report.timestamp }
        case "Ciudad":
            filteredReports = reports // Por ahora mostramos todos, podríamos filtrar por ciudad si agregamos esa información
        default:
            filteredReports = reports
        }
    }

    /// Obtiene el número de comentarios de un reporte
    func getCommentCount(for reportId: String, completion: @escaping (Int) -> Void) {
        db.collection("reportes").document(reportId)
            .collection("comentarios")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting comment count: \(error.localizedDescription)")
                    completion(0)
                    return
                }
                
                completion(snapshot?.documents.count ?? 0)
            }
    }

    func fetchSpecificReport(_ reportId: String, completion: @escaping (Report?) -> Void) {
        db.collection("reportes").document(reportId).getDocument { snapshot, error in
            guard let document = snapshot,
                  let data = document.data() else {
                completion(nil)
                return
            }
            
            guard let latitude = data["latitude"] as? Double,
                  let longitude = data["longitude"] as? Double,
                  let typeTitle = data["type"] as? String,
                  let description = data["description"] as? String,
                  let timestamp = data["timestamp"] as? Timestamp,
                  let userId = data["userId"] as? String,
                  let type = self.reportTypes.first(where: { $0.title == typeTitle }) else {
                completion(nil)
                return
            }
            
            let likes = data["likes"] as? Int ?? 0
            
            let report = Report(
                id: document.documentID,
                type: type,
                description: description,
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                likes: likes,
                timestamp: timestamp.dateValue(),
                userId: userId
            )
            
            completion(report)
        }
    }
}
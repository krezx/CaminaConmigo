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
    @Published var selectedAddress: String = "Seleccionar ubicación"
    @Published var isLoadingCity = false

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
                let isAnonymous = data["isAnonymous"] as? Bool ?? false
                let imageUrls = data["imageUrls"] as? [String] ?? []
                
                var report = Report(
                    id: document.documentID,
                    type: type,
                    description: description,
                    coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    isAnonymous: isAnonymous,
                    likes: likes,
                    timestamp: timestamp.dateValue(),
                    userId: userId
                )
                report.imageUrls = imageUrls
                
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
    func submitReport(images: [UIImage]) {
        guard let report = currentReport else { return }
        guard let coordinate = selectedLocation else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        currentReport?.coordinate = coordinate
        
        var reportData: [String: Any] = [
            "type": report.type.title,
            "description": report.description,
            "isAnonymous": report.isAnonymous,
            "timestamp": Timestamp(date: Date()),
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "likes": 0,
            "userId": currentUserId,
            "imageUrls": []
        ]
        
        if images.isEmpty {
            saveReportData(reportData) { reportId in
                if !report.isAnonymous {
                    self.notifyFriends(reportId: reportId, report: report)
                }
            }
        } else {
            uploadImages(images) { urls in
                reportData["imageUrls"] = urls
                self.saveReportData(reportData) { reportId in
                    if !report.isAnonymous {
                        self.notifyFriends(reportId: reportId, report: report)
                    }
                }
            }
        }
    }
    
    private func uploadImages(_ images: [UIImage], completion: @escaping ([String]) -> Void) {
        let group = DispatchGroup()
        var urls: [String] = []
        
        for image in images {
            group.enter()
            
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                group.leave()
                continue
            }
            
            let storageRef = storage.reference().child("report_images/\(UUID().uuidString).jpg")
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    group.leave()
                    return
                }
                
                storageRef.downloadURL { url, error in
                    if let url = url {
                        urls.append(url.absoluteString)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(urls)
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
                    
                    // Para cada amigo, verificar sus preferencias de notificación
                    for doc in documents {
                        let friendId = doc.documentID
                        
                        // Verificar si el amigo tiene activadas las notificaciones de reportes
                        self.db.collection("users").document(friendId).getDocument { friendSnapshot, error in
                            guard let friendData = friendSnapshot?.data(),
                                let reportNotificationsEnabled = friendData["reportNotifications"] as? Bool,
                                reportNotificationsEnabled else { return }
                            
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
                            
                            // Guardar la notificación en Firestore solo si las notificaciones están activadas
                            try? self.db.collection("users")
                                .document(friendId)
                                .collection("notifications")
                                .document()
                                .setData(from: notification)
                        }
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
            // Ordenar por número de likes
            filteredReports = reports.sorted { $0.report.likes > $1.report.likes }
        case "Recientes":
            // Ordenar por fecha más reciente
            filteredReports = reports.sorted { $0.report.timestamp > $1.report.timestamp }
        case "Ciudad":
            isLoadingCity = true
            Task {
                await groupReportsByCity()
                await MainActor.run {
                    isLoadingCity = false
                }
            }
        default:
            filteredReports = reports
        }
    }

    @MainActor
    private func groupReportsByCity() async {
        let geocoder = CLGeocoder()
        var reportsWithCity: [(report: ReportAnnotation, city: String)] = []
        
        // Obtener la ciudad actual del usuario para ordenar primero los reportes de su ciudad
        let currentLocation = FilterLocationManager.shared.getCurrentLocation()
        var userCity = "ZZZ" // Valor por defecto para ordenar al final si no se encuentra la ciudad
        
        if let currentLocation = currentLocation {
            if let placemark = try? await geocoder.reverseGeocodeLocation(CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)).first,
               let city = placemark.locality {
                userCity = city
            }
        }
        
        // Procesar cada reporte para obtener su ciudad
        for report in reports {
            let location = CLLocation(latitude: report.coordinate.latitude, longitude: report.coordinate.longitude)
            if let placemark = try? await geocoder.reverseGeocodeLocation(location).first,
               let city = placemark.locality {
                reportsWithCity.append((report: report, city: city))
            }
        }
        
        // Ordenar primero por ciudad (la ciudad del usuario primero) y luego por fecha
        filteredReports = reportsWithCity
            .sorted { (report1, report2) -> Bool in
                if report1.city == userCity && report2.city != userCity {
                    return true
                }
                if report2.city == userCity && report1.city != userCity {
                    return false
                }
                if report1.city == report2.city {
                    return report1.report.report.timestamp > report2.report.report.timestamp
                }
                return report1.city < report2.city
            }
            .map { $0.report }
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
            let isAnonymous = data["isAnonymous"] as? Bool ?? true
            let imageUrls = data["imageUrls"] as? [String] ?? []
            
            var report = Report(
                id: document.documentID,
                type: type,
                description: description,
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                isAnonymous: isAnonymous,
                likes: likes,
                timestamp: timestamp.dateValue(),
                userId: userId
            )
            report.imageUrls = imageUrls
            
            completion(report)
        }
    }

    /// Obtiene el nombre de usuario del autor del reporte
    func fetchAuthorUsername(userId: String, completion: @escaping (String?) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching author username: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let data = snapshot?.data(),
               let username = data["username"] as? String {
                completion(username)
            } else {
                completion(nil)
            }
        }
    }
}

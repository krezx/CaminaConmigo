//
//  MapViewModel.swift
//  CaminaConmigo
//
//  Created by a on 28-01-25.
//

import SwiftUI
import MapKit
import FirebaseFirestore

/// ViewModel para gestionar la lógica de la vista del mapa.
class MapViewModel: ObservableObject {
    @Published var reports: [ReportAnnotation] = []
    @Published var selectedReport: ReportAnnotation?
    @Published var showReportDetail: Bool = false
    
    private let db = Firestore.firestore()
    
    init() {
        fetchReports()
    }
    
    func fetchReports() {
        db.collection("reports").addSnapshotListener { [weak self] querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching reports: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self?.reports = documents.compactMap { document -> ReportAnnotation? in
                do {
                    let report = try document.data(as: Report.self)
                    return ReportAnnotation(report: report)
                } catch {
                    print("Error decoding report: \(error.localizedDescription)")
                    return nil
                }
            }
        }
    }
    
    func selectReport(_ report: ReportAnnotation) {
        selectedReport = report
        showReportDetail = true
    }
    
    func closeReportDetail() {
        selectedReport = nil
        showReportDetail = false
    }
}
//
//  ReportAnnotation.swift
//  CaminaConmigo
//
//  Created by a on 30-01-25.
//

import MapKit

class ReportAnnotation: NSObject, MKAnnotation, Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let report: Report
    
    var title: String? { report.type.title }
    var subtitle: String? { report.description }
    
    init(report: Report) {
        self.report = report
        self.coordinate = report.coordinate ?? CLLocationCoordinate2D()
        super.init()
    }
} 

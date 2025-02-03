//
//  ReportAnnotation.swift
//  CaminaConmigo
//
//  Created by a on 30-01-25.
//

import MapKit

class ReportAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let type: String
    let reportDescription: String
    
    // Requerido por MKAnnotation
    var title: String? { type }
    var subtitle: String? { reportDescription }
    
    init(coordinate: CLLocationCoordinate2D, type: String, description: String) {
        self.coordinate = coordinate
        self.type = type
        self.reportDescription = description
        super.init()
    }
} 
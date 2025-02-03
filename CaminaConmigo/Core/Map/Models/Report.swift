//
//  Report.swift
//  CaminaConmigo
//
//  Created by a on 23-01-25.
//

import UIKit // Importa el framework UIKit para trabajar con objetos visuales como UIImage.
import Foundation // Importa el framework Foundation para trabajar con estructuras de datos, como UUID.
import CoreLocation
import MapKit

/// Estructura que representa un reporte realizado por el usuario.
struct Report: Identifiable {
    let id = UUID()
    var type: ReportType
    var description: String
    var coordinate: CLLocationCoordinate2D?
    var isAnonymous: Bool = true
    var images: [UIImage] = []
    var timestamp: Date = Date()
    var likes: Int = 0
}

/// Estructura que representa un tipo de reporte en la aplicación.
struct ReportType: Identifiable {
    let id = UUID() // Un identificador único para cada tipo de reporte, generado de forma automática.
    let title: String // Título descriptivo del tipo de reporte (por ejemplo, "Accidente", "Emergencia").
    let imageName: String // Nombre de la imagen asociada al tipo de reporte, que se utiliza para mostrar un ícono representativo.
    
    // Nombre de la imagen con el prefijo 'i_' para los marcadores del mapa
    var markerImageName: String {
        "i_\(imageName)"
    }
}
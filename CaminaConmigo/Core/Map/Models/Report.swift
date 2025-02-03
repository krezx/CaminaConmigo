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
import FirebaseFirestore

/// Estructura que representa un reporte realizado por el usuario.
struct Report: Identifiable, Codable {
    @DocumentID var id: String?
    var type: ReportType
    var description: String
    var coordinate: CLLocationCoordinate2D?
    var isAnonymous: Bool = true
    var images: [UIImage] = []
    var timestamp: Date = Date()
    var likes: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case description
        case latitude
        case longitude
        case isAnonymous
        case timestamp
        case likes
    }
    
    init(id: String? = nil, type: ReportType, description: String, coordinate: CLLocationCoordinate2D? = nil, isAnonymous: Bool = true, likes: Int = 0) {
        self.id = id
        self.type = type
        self.description = description
        self.coordinate = coordinate
        self.isAnonymous = isAnonymous
        self.likes = likes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        type = try container.decode(ReportType.self, forKey: .type)
        description = try container.decode(String.self, forKey: .description)
        isAnonymous = try container.decode(Bool.self, forKey: .isAnonymous)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        likes = try container.decode(Int.self, forKey: .likes)
        
        // Decodificar coordenadas
        if let latitude = try container.decodeIfPresent(Double.self, forKey: .latitude),
           let longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            coordinate = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(description, forKey: .description)
        try container.encode(isAnonymous, forKey: .isAnonymous)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(likes, forKey: .likes)
        
        // Codificar coordenadas
        if let coordinate = coordinate {
            try container.encode(coordinate.latitude, forKey: .latitude)
            try container.encode(coordinate.longitude, forKey: .longitude)
        }
    }
}

/// Estructura que representa un tipo de reporte en la aplicación.
struct ReportType: Identifiable, Codable {
    let id = UUID() // Un identificador único para cada tipo de reporte, generado de forma automática.
    let title: String // Título descriptivo del tipo de reporte (por ejemplo, "Accidente", "Emergencia").
    let imageName: String // Nombre de la imagen asociada al tipo de reporte, que se utiliza para mostrar un ícono representativo.
    
    // Nombre de la imagen con el prefijo 'i_' para los marcadores del mapa
    var markerImageName: String {
        "i_\(imageName)"
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case imageName
    }
}

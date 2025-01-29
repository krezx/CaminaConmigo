//
//  Report.swift
//  CaminaConmigo
//
//  Created by a on 23-01-25.
//

import UIKit // Importa el framework UIKit para trabajar con objetos visuales como UIImage.
import Foundation // Importa el framework Foundation para trabajar con estructuras de datos, como UUID.


/// Estructura que representa un reporte realizado por el usuario.
struct Report {
    var type: ReportType // Tipo de reporte, se especifica a través del enum ReportType.
    var description: String // Descripción del reporte, proporciona detalles sobre el incidente o situación.
    var location: String // Ubicación asociada con el reporte.
    var isAnonymous: Bool = true // Define si el reporte es anónimo o no. Por defecto es anónimo.
    var images: [UIImage] = [] // Lista de imágenes asociadas con el reporte. Puede contener varias imágenes.
}

/// Estructura que representa un tipo de reporte en la aplicación.
struct ReportType: Identifiable {
    let id = UUID() // Un identificador único para cada tipo de reporte, generado de forma automática.
    let title: String // Título descriptivo del tipo de reporte (por ejemplo, "Accidente", "Emergencia").
    let imageName: String // Nombre de la imagen asociada al tipo de reporte, que se utiliza para mostrar un ícono representativo.
}
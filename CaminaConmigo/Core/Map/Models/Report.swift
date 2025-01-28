//
//  Report.swift
//  CaminaConmigo
//
//  Created by a on 23-01-25.
//

import UIKit // Importa el framework UIKit para trabajar con objetos visuales como UIImage.

/// Estructura que representa un reporte realizado por el usuario.
struct Report {
    var type: ReportType // Tipo de reporte, se especifica a través del enum ReportType.
    var description: String // Descripción del reporte, proporciona detalles sobre el incidente o situación.
    var location: String // Ubicación asociada con el reporte.
    var isAnonymous: Bool = true // Define si el reporte es anónimo o no. Por defecto es anónimo.
    var images: [UIImage] = [] // Lista de imágenes asociadas con el reporte. Puede contener varias imágenes.
}

//
//  ReportType.swift
//  CaminaConmigo
//
//  Created by a on 23-01-25.
//

import Foundation // Importa el framework Foundation para trabajar con estructuras de datos, como UUID.

/// Estructura que representa un tipo de reporte en la aplicación.
struct ReportType: Identifiable {
    let id = UUID() // Un identificador único para cada tipo de reporte, generado de forma automática.
    let title: String // Título descriptivo del tipo de reporte (por ejemplo, "Accidente", "Emergencia").
    let imageName: String // Nombre de la imagen asociada al tipo de reporte, que se utiliza para mostrar un ícono representativo.
}

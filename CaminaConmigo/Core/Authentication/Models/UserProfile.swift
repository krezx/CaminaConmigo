//
//  UserProfile.swift
//  CaminaConmigo
//
//  Created by a on 28-01-25.
//

import Foundation // Importa el framework Foundation para manejar datos como fechas y codificación.

/// Estructura que representa el perfil de un usuario.
/// Conforma el protocolo `Codable` para permitir la conversión a y desde formatos de datos como JSON.
struct UserProfile: Codable {
    var id: String // Identificador único del usuario.
    var name: String // Nombre completo del usuario.
    var username: String // Nombre de usuario.
    var profileType: String // Tipo de perfil (por ejemplo, "Público", "Privado").
    var joinDate: Date // Fecha en la que el usuario se unió a la plataforma.
    var photoURL: String? // URL de la foto de perfil (opcional).

    /// Inicializador para crear un perfil de usuario.
    /// - Parameters:
    ///   - id: El identificador único del usuario.
    ///   - name: El nombre completo del usuario (por defecto es una cadena vacía).
    ///   - username: El nombre de usuario (por defecto es una cadena vacía).
    ///   - profileType: El tipo de perfil del usuario (por defecto es "Público").
    ///   - photoURL: La URL de la foto de perfil (por defecto es nil).
    init(id: String, name: String = "", username: String = "", profileType: String = "Público", photoURL: String? = nil) {
        self.id = id // Asigna el identificador del usuario.
        self.name = name // Asigna el nombre del usuario.
        self.username = username // Asigna el nombre de usuario.
        self.profileType = profileType // Asigna el tipo de perfil (por defecto "Público").
        self.joinDate = Date() // Asigna la fecha actual como la fecha de unión del usuario.
        self.photoURL = photoURL // Asigna la URL de la foto de perfil (puede ser nil).
    }
}

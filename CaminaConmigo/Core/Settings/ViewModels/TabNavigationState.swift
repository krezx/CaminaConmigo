//
//  TabNavigationState.swift
//  CaminaConmigo
//
//  Created by a on 23-01-25.
//

import Foundation

/// Clase que maneja el estado de la pestaña seleccionada en la navegación de la aplicación.
/// Esta clase se utiliza para rastrear qué pestaña está actualmente seleccionada, permitiendo una navegación fluida.
class TabNavigationState: ObservableObject {
    
    /// Propiedad que almacena el índice de la pestaña seleccionada.
    /// El valor `4` se usa como índice predeterminado para la pestaña "Menú".
    @Published var selectedTab = 4  // 4 es el índice para Menú
}

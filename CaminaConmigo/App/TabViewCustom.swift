//
//  TabViewCustom.swift
//  CaminaConmigo
//
//  Created by a on 20-01-25.
//

import SwiftUI

/// Estructura que define una vista de pestañas personalizada.
struct TabViewCustom: View {
    @EnvironmentObject private var navigationState: NavigationState // Estado global de navegación
    
    /// Inicializador que configura la apariencia de la barra de pestañas.
    init() {
        let appearance = UITabBarAppearance() // Crea una nueva apariencia para la barra de pestañas.
        appearance.configureWithOpaqueBackground() // Configura el fondo de la barra de pestañas como opaco.
        appearance.backgroundColor = UIColor(red: 239/255, green: 96/255, blue: 152/255, alpha: 1.0) // Establece el color de fondo.
        
        // Configuración de los colores de los íconos y texto en la barra de pestañas.
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.5) // Color gris claro para íconos no seleccionados.
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white // Color blanco para el ícono seleccionado.
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)] // Color gris para texto no seleccionado.
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white] // Color blanco para texto seleccionado.
        
        // Aplicar la apariencia configurada a la barra de pestañas.
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    /// Cuerpo de la vista que define el contenido de la barra de pestañas.
    var body: some View {
        TabView(selection: $navigationState.selectedTab) { // Crea un TabView enlazado al estado de navegación.
            MapView() // Vista del mapa.
                .tabItem { // Elemento de la pestaña del mapa.
                    Image(systemName: "map")
                    Text("Mapa")
                }
                .tag(0) // Etiqueta para identificar esta pestaña.
                
            NovedadView() // Vista de novedades.
                .tabItem { // Elemento de la pestaña de novedades.
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("Novedad")
                }
                .tag(1) // Etiqueta para identificar esta pestaña.
                
            ChatListView() // Vista de lista de chats.
                .tabItem { // Elemento de la pestaña de chats.
                    Image(systemName: "ellipsis.message")
                    Text("Chats")
                }
                .tag(2) // Etiqueta para identificar esta pestaña.
                .badge(navigationState.unreadMessagesCount > 0 ? String(navigationState.unreadMessagesCount) : nil)
                
            AyudaView() // Vista de ayuda.
                .tabItem { // Elemento de la pestaña de ayuda.
                    Image(systemName: "phone.and.waveform")
                    Text("Ayuda")
                }
                .tag(3) // Etiqueta para identificar esta pestaña.
                
            MenuView() // Vista de menú.
                .tabItem { // Elemento de la pestaña de menú.
                    Image(systemName: "line.horizontal.3")
                    Text("Menú")
                }
                .tag(4) // Etiqueta para identificar esta pestaña.
        }
    }
}

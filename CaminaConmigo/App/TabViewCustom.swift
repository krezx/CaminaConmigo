//
//  TabViewCustom.swift
//  CaminaConmigo
//
//  Created by a on 20-01-25.
//
import SwiftUI

struct TabViewCustom: View {
    @StateObject private var navigationState = TabNavigationState()
    
    init() {
        // Cambiar el color de fondo de la barra de pestañas
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 239/255, green: 96/255, blue: 152/255, alpha: 1.0)
        
        
        // Cambiar el color de los íconos no seleccionados
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.5) // Color gris claro para íconos no seleccionados
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white // Color blanco para el ícono seleccionado
        
        // Cambiar el color del texto no seleccionado
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)] // Color gris para texto no seleccionado
        
        // Cambiar el color del texto seleccionado
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white] // Color blanco para texto seleccionado
        
        // Aplicar la apariencia
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $navigationState.selectedTab) {
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Mapa")
                }
                .tag(0)
            NovedadView()
                .tabItem {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("Novedad")
                }
                .tag(1)
            ChatListView()
                .tabItem {
                    Image(systemName: "ellipsis.message")
                    Text("Chats")
                }
                .tag(2)
            AyudaView()
                .tabItem {
                    Image(systemName: "phone.and.waveform")
                    Text("Ayuda")
                }
                .tag(3)
            MenuView()
                .tabItem {
                    Image(systemName: "line.horizontal.3")
                    Text("Menú")
                }
                .tag(4)
        }
        .environmentObject(navigationState)
    }
}

#Preview {
    TabViewCustom()
}

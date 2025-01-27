//
//  MenuView.swift
//  CaminaConmigo
//
//  Created by a on 20-01-25.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var navigationState: TabNavigationState
    @State private var navigateToProfile = false
    @State private var navigateToChats = false
    @State private var navigateToEmergencyContacts = false
    @State private var navigateToNotifications = false
    @State private var navigateToInviteFriends = false
    @State private var navigateToSuggestions = false
    @State private var navigateToSettings = false

    var body: some View {
        NavigationStack {
            VStack {
                // Perfil Section
                VStack(alignment: .leading, spacing: 0) {
                    SectionHeader(title: "Perfil")
                    
                    NavigationLink {
                        ProfileView()
                    } label: {
                        MenuItem(icon: "person.circle", title: "Mi perfil")
                    }
                    
                    Button {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = scene.windows.first {
                            window.rootViewController?.dismiss(animated: true)
                        }
                        withAnimation {
                            navigationState.selectedTab = 2  // Cambiar a Chats
                        }
                    } label: {
                        MenuItem(icon: "bubble.left.and.bubble.right", title: "Chats")
                    }
                    
                    NavigationLink {
                        EmergencyContactsView()
                    } label: {
                        MenuItem(icon: "phone.and.waveform", title: "Contactos de emergencia")
                    }
                    
                    NavigationLink {
                        NotificationsView()
                    } label: {
                        MenuItem(icon: "bell.circle", title: "Notificaciones")
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Divider with shadow
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    .shadow(color: .black, radius: 4, x: 0, y: 2)
                    .padding(.vertical, 10)
                
                // Ajustes y Más Section
                VStack(alignment: .leading, spacing: 0) {
                    SectionHeader(title: "Ajustes y Más")
                    
                    NavigationLink {
                        ShareView()
                    } label: {
                        MenuItem(icon: "person.crop.circle.badge.plus", title: "Invitar amigos")
                    }
                    
                    NavigationLink {
                        SugerenciasView()
                    } label: {
                        MenuItem(icon: "message", title: "Sugerencias")
                    }
                    
                    NavigationLink {
                        ConfigView()
                    } label: {
                        MenuItem(icon: "gearshape", title: "Configuración")
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Footer
                VStack {
                    Button(action: {
                        // Acción de cerrar sesión
                    }) {
                        Text("Cerrar sesión")
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 30).stroke(Color.init(uiColor: UIColor(red: 239/255, green: 96/255, blue: 152/255, alpha: 1.0)), lineWidth: 1))
                            .padding(.horizontal, 110)
                    }
                    
                    VStack(spacing: 0) {
                        Image("logo1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                        Text("Copyright 2025®")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 10)
                }
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarBackButtonHidden(true)
            .tint(.black)
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.black)
    }
}

struct MenuItem: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 30, height: 30)
                .foregroundColor(.black)
            
            Text(title)
                .font(.body)
                .foregroundColor(.black)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    MenuView()
}

//
//  MenuView.swift
//  CaminaConmigo
//
//  Created by a on 20-01-25.
//

import SwiftUI

/// Vista que muestra el menú principal de la aplicación, proporcionando opciones para el perfil,
/// chats, contactos de emergencia, notificaciones, invitaciones, sugerencias, configuración y cerrar sesión.
struct MenuView: View {
    @EnvironmentObject var navigationState: TabNavigationState  // Estado de navegación de las pestañas.
    @EnvironmentObject var authViewModel: AuthenticationViewModel  // Vista de autenticación para manejar sesión.
    
    // Propiedades de estado para controlar las transiciones de navegación.
    @State private var navigateToProfile = false
    @State private var navigateToChats = false
    @State private var navigateToEmergencyContacts = false
    @State private var navigateToNotifications = false
    @State private var navigateToInviteFriends = false
    @State private var navigateToSuggestions = false
    @State private var navigateToSettings = false
    @State private var showGuestAlert = false  // Alerta cuando el usuario está en modo invitado y trata de acceder a su perfil.

    var body: some View {
        NavigationStack {
            VStack {
                // Sección de Perfil
                VStack(alignment: .leading, spacing: 0) {
                    SectionHeader(title: "Perfil")
                    
                    // Si el usuario está en modo invitado, mostrar un botón para iniciar sesión.
                    if authViewModel.isGuestMode {
                        Button {
                            // Mostrar alerta para iniciar sesión.
                            showGuestAlert = true
                        } label: {
                            MenuItem(icon: "person.circle", title: "Mi perfil")
                        }
                    } else {
                        // Si no es invitado, se muestra un enlace de navegación al perfil.
                        NavigationLink {
                            ProfileView()
                        } label: {
                            MenuItem(icon: "person.circle", title: "Mi perfil")
                        }
                    }
                    
                    // Botón de Chats que cambia la vista activa a la pestaña de Chats.
                    Button {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = scene.windows.first {
                            window.rootViewController?.dismiss(animated: true)
                        }
                        withAnimation {
                            navigationState.selectedTab = 2  // Cambiar a la pestaña de Chats.
                        }
                    } label: {
                        MenuItem(icon: "bubble.left.and.bubble.right", title: "Chats")
                    }
                    
                    // Enlace a Contactos de Emergencia.
                    NavigationLink {
                        EmergencyContactsView()
                    } label: {
                        MenuItem(icon: "phone.and.waveform", title: "Contactos de emergencia")
                    }
                    
                    // Enlace a Notificaciones.
                    NavigationLink {
                        NotificationsView()
                    } label: {
                        MenuItem(icon: "bell.circle", title: "Notificaciones")
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Separador con sombra para organizar las secciones.
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    .shadow(color: .black, radius: 4, x: 0, y: 2)
                    .padding(.vertical, 10)
                
                // Sección de Ajustes y Más
                VStack(alignment: .leading, spacing: 0) {
                    SectionHeader(title: "Ajustes y Más")
                    
                    // Enlace para invitar amigos.
                    NavigationLink {
                        ShareView()
                    } label: {
                        MenuItem(icon: "person.crop.circle.badge.plus", title: "Invitar amigos")
                    }
                    
                    // Enlace para sugerencias.
                    NavigationLink {
                        SugerenciasView()
                    } label: {
                        MenuItem(icon: "message", title: "Sugerencias")
                    }
                    
                    // Enlace para configuración.
                    NavigationLink {
                        ConfigView()
                    } label: {
                        MenuItem(icon: "gearshape", title: "Configuración")
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Footer con botón de cierre de sesión o inicio de sesión y la información de copyright.
                VStack {
                    Button(action: {
                        authViewModel.signOut()  // Cerrar sesión si el usuario está autenticado.
                    }) {
                        Text(authViewModel.isGuestMode ? "Iniciar sesión" : "Cerrar sesión")
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.init(uiColor: UIColor(red: 239/255, green: 96/255, blue: 152/255, alpha: 1.0)), lineWidth: 1))
                            .padding(.horizontal, 110)
                    }
                    
                    VStack(spacing: 0) {
                        // Logo y copyright en el pie de página.
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
            .background(Color(UIColor.systemBackground))  // Fondo de la vista.
            .navigationBarBackButtonHidden(true)  // Oculta el botón de retroceso.
            .tint(.black)
            .alert("Iniciar sesión", isPresented: $showGuestAlert) {  // Alerta de inicio de sesión.
                Button("Cancelar", role: .cancel) {}
                Button("Iniciar sesión") {
                    authViewModel.signOut()  // Desloguear al usuario y redirigir a la pantalla de login.
                }
            } message: {
                Text("Debes iniciar sesión para acceder a tu perfil")
            }
        }
    }
}

/// Vista reutilizable para el encabezado de cada sección del menú.
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.black)
    }
}

/// Vista reutilizable para los ítems del menú, con icono y título.
struct MenuItem: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)  // Icono de la opción.
                .font(.title3)
                .frame(width: 30, height: 30)
                .foregroundColor(.black)
            
            Text(title)  // Título de la opción.
                .font(.body)
                .foregroundColor(.black)
            
            Spacer()
            
            Image(systemName: "chevron.right")  // Indicador de navegación.
                .foregroundColor(.gray)
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    MenuView()  // Previsualización del menú.
}

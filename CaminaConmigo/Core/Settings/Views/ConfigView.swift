//
//  ConfigView.swift
//  CaminaConmigo
//
//  Created by a on 21-01-25.
//

import SwiftUI

/// Vista que permite a los usuarios configurar las preferencias de la aplicación,
/// como notificaciones, modo oscuro y la activación del shake para interacciones rápidas.
struct ConfigView: View {
    @Environment(\.dismiss) private var dismiss  // Permite cerrar la vista.
    
    // Propiedades de estado para manejar las configuraciones de usuario.
    @State private var groupNotifications = true  // Activar/desactivar notificaciones de grupos.
    @State private var reportNotifications = false  // Activar/desactivar notificaciones de reportes.
    @State private var darkMode = false  // Activar/desactivar el modo oscuro.
    @AppStorage("shakeEnabled") private var shakeEnabled = true  // Activar/desactivar la funcionalidad de shake.
    
    var body: some View {
        NavigationView {
            VStack {
                // Barra de encabezado con un botón para cerrar la vista y el título "Configuración".
                HStack {
                    Button(action: {
                        dismiss()  // Cierra la vista de configuración.
                    }) {
                        Image(systemName: "arrow.left")  // Icono de flecha para regresar.
                            .foregroundColor(.black)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text("Configuración")  // Título de la vista.
                        .font(.title)
                        .bold()
                    
                    Spacer()  // Para balancear el espacio en la barra superior.
                }
                .padding(5)
                .background(Color(UIColor.systemBackground))  // Fondo de la barra.
                .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)  // Sombra sutil para la barra.

                // Lista de configuraciones con varios Toggles para permitir al usuario modificar sus preferencias.
                List {
                    // Toggle para notificaciones de grupos.
                    Toggle("Notificaciones de grupos", isOn: $groupNotifications)
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 5)

                    // Toggle para notificaciones de reportes.
                    Toggle("Notificaciones de reporte", isOn: $reportNotifications)
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 5)

                    // Toggle para habilitar el modo oscuro.
                    Toggle("Modo oscuro", isOn: $darkMode)
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 5)

                    // Toggle para habilitar el comportamiento de shake.
                    Toggle("Shake", isOn: $shakeEnabled)
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 5)
                }
                .listStyle(PlainListStyle())  // Estilo de lista sin separación entre elementos.
            }
            .background(Color(UIColor.systemBackground))  // Fondo de la vista.
        }
        .navigationBarHidden(true)  // Oculta la barra de navegación.
        .toolbar(.hidden, for: .tabBar)  // Oculta la barra de pestañas.
    }
}

/// Vista previa para previsualizar la vista de configuración en el canvas de Xcode.
#Preview {
    ConfigView()  // Previsualización de la vista de configuración.
}

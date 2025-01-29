//
//  NotificationsView.swift
//  CaminaConmigo
//
//  Created by a on 21-01-25.
//

import SwiftUI

/// Vista que muestra una lista de notificaciones para el usuario, mostrando eventos importantes o actualizaciones,
/// como unirse a grupos, recibir ayuda o hacer un reporte.
struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss  // Permite cerrar la vista de notificaciones.
    
    // Lista de notificaciones con un mensaje y una fecha asociada.
    var notifications = [
        ("Pepe Contreras de tu grupo Amigos necesita ayuda!", "Hoy"),
        ("Marcelo de tus contactos se ha unido a Camina Conmigo, ¡Salúdalo!", "Ayer"),
        ("Jose de tus contactos ha hecho un reporte", "15/01"),
        ("Victor ha comentado un reporte que has hecho", "14/01"),
        ("Has hecho un reporte, Muchas gracias por tu aporte!", "12/01"),
        ("¡Pepe Contreras ha formado un grupo con Victor!", "09/01"),
        ("¡Pepe Contreras te ha unido a Camina conmigo!", "02/01")
    ]
    
    var body: some View {
        VStack {
            // Barra superior con un botón para cerrar la vista y el título de "Notificaciones".
            HStack {
                Button(action: {
                    dismiss()  // Cierra la vista cuando se presiona el botón.
                }) {
                    Image(systemName: "arrow.left")  // Icono de flecha para regresar.
                        .foregroundColor(.black)
                        .font(.title2)
                }
                Spacer()
                Text("Notificaciones")  // Título de la vista.
                    .font(.title)
                    .bold()
                    .padding(.vertical, 5)
                Spacer()
            }
            .frame(maxWidth:  .infinity)
            .background(Color.white)  // Fondo blanco para la barra superior.
            .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)  // Sombra para darle profundidad a la barra superior.
            
            // Vista de navegación para mostrar la lista de notificaciones.
            NavigationView {
                List(notifications, id: \.0) { notification in
                    HStack {
                        // Icono circular con la letra "P" en color blanco y fondo rosa, representando al emisor.
                        Circle()
                            .frame(width: 40, height: 40)
                            .overlay(Text("P").foregroundColor(.white))  // Letra "P" de Pepe, por ejemplo.
                            .foregroundColor(.pink)  // Color de fondo del círculo (rosa).
                        
                        HStack(spacing: 5) {
                            // Texto de la notificación con el mensaje principal.
                            Text(notification.0)
                                .font(.body)
                                .foregroundColor(.black)  // Color del texto.
                            
                            Spacer()
                            
                            // Fecha asociada con la notificación.
                            Text(notification.1)
                                .font(.footnote)
                                .foregroundColor(.gray)  // Color gris para la fecha.
                        }
                    }
                    .padding(.vertical, 10)  // Espaciado vertical para separar las notificaciones.
                }
            }
        }
        .navigationBarHidden(true)  // Oculta la barra de navegación de la vista.
        .toolbar(.hidden, for: .tabBar)  // Oculta la barra de pestañas (tab bar).
    }
}

/// Vista previa para previsualizar la vista de notificaciones en el canvas de Xcode.
struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()  // Previsualización de la vista de notificaciones.
    }
}

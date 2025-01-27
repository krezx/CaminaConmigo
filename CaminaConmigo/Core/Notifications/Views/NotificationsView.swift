//
//  NotificationsView.swift
//  CaminaConmigo
//
//  Created by a on 21-01-25.
//


import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
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
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                        .font(.title2)
                }
                Spacer()
                Text("Notificaciones")
                    .font(.title)
                    .bold()
                    .padding(.vertical, 5)
                Spacer()
            }
            .frame(maxWidth:  .infinity)
            .background(Color.white)
            .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
            
            NavigationView {
                List(notifications, id: \.0) { notification in
                    HStack {
                        Circle()
                            .frame(width: 40, height: 40)
                            .overlay(Text("P").foregroundColor(.white))
                            .foregroundColor(.pink)
                        
                        HStack(spacing: 5) {
                            Text(notification.0)
                                .font(.body)
                                .foregroundColor(.black)
                            Spacer()
                            Text(notification.1)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}

//
//  ShareView.swift
//  CaminaConmigo
//
//  Created by a on 22-01-25.
//

import SwiftUI

/// Vista que permite al usuario invitar amigos a unirse a la aplicación, con un mensaje de invitación
/// y la opción de compartirlo a través de un controlador de actividad.
struct ShareView: View {
    @Environment(\.dismiss) private var dismiss  // Permite cerrar la vista cuando sea necesario.
    
    var body: some View {
        VStack {
            // Encabezado con botón de retroceso
            HStack {
                Button(action: {
                    dismiss()  // Cierra la vista cuando se presiona el botón.
                }) {
                    Image(systemName: "arrow.left")  // Icono de flecha hacia atrás.
                        .foregroundColor(.black)
                        .font(.title2)
                }
                
                Spacer()
                
                Text("Invitar amigos")  // Título de la vista.
                    .font(.title)
                    .bold()
                
                Spacer() // Para balancear el espacio y centrar el título.
            }
            .padding(5)
            .background(Color(UIColor.systemBackground))  // Fondo de la cabecera.
            .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)  // Sombra para el encabezado.
            
            Spacer()  // Espacio entre el encabezado y el contenido.
            
            VStack(spacing: 10) {
                // Imagen principal de la vista.
                Image("abrazo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350)
                
                // Texto principal debajo de la imagen.
                Text("Caminando juntos caminamos seguros🤝")
                    .font(.title3)
                    .bold()
                
                // Sección de texto adicional explicando la invitación.
                VStack {
                    HStack {
                        Text("¡Ayúdanos a hacer que CaminaConmigo sea aún mejor!")
                            .font(.system(size: 13))
                            .lineLimit(1)  // Limita a una sola línea.
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.gray)
                    }
                    
                    Text("Invita a tus amigos a unirse, y juntos construiremos una comunidad más segura.")
                        .font(.system(size: 13))
                        .padding(.horizontal, 10)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 10)
            }
            Spacer()  // Espacio antes del botón de invitación.
            
            // Botón de invitación que activa el controlador de actividades.
            Button(action: {
                let mensaje = "¡Únete a CaminaConmigo! Juntos podemos crear una comunidad más segura. Descarga la app aquí: https://apps.apple.com/app/caminaconmigo"
                let activityVC = UIActivityViewController(activityItems: [mensaje], applicationActivities: nil)
                
                // Obtener la ventana actual para presentar el controlador de actividad.
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    rootVC.present(activityVC, animated: true)  // Presentar el controlador de actividad.
                }
            }) {
                HStack {
                    Spacer()
                    Text("INVITAR AMIGOS")  // Texto en el botón de invitación.
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 10)
            }
            .frame(width: 300, height: 40)  // Establecer el tamaño específico del botón.
            .background(Color.init(uiColor: UIColor(red: 239/255, green: 96/255, blue: 152/255, alpha: 1.0)))  // Color de fondo.
            .cornerRadius(35)  // Bordes redondeados del botón.
            .padding(.vertical, 30)  // Espaciado vertical alrededor del botón.
        }
        .navigationBarHidden(true)  // Ocultar la barra de navegación para una experiencia más limpia.
        .toolbar(.hidden, for: .tabBar)  // Ocultar la barra de pestañas en esta vista.
    }
}

#Preview {
    ShareView()  // Vista previa de la vista ShareView.
}

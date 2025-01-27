//
//  ShareView.swift
//  CaminaConmigo
//
//  Created by a on 22-01-25.
//

import SwiftUI

struct ShareView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            // Encabezado
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                        .font(.title2)
                }
                
                Spacer()
                
                Text("Invitar amigos")
                    .font(.title)
                    .bold()
                
                Spacer() // Para balancear el espacio
            }
            .padding(5)
            .background(Color(UIColor.systemBackground))
            .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
            Spacer()
            VStack(spacing: 10){
                Image("abrazo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350)
                Text("Caminando juntos caminamos seguros🤝")
                    .font(.title3)
                    .bold()
                VStack {
                        HStack {
                            Text("¡Ayúdanos a hacer que CaminaConmigo sea aún mejor!")
                                .font(.system(size: 13))
                                .lineLimit(1)  // Limita a una sola línea
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
            Spacer()
            Spacer()
            Button(action: {
                let mensaje = "¡Únete a CaminaConmigo! Juntos podemos crear una comunidad más segura. Descarga la app aquí: https://apps.apple.com/app/caminaconmigo"
                let activityVC = UIActivityViewController(activityItems: [mensaje], applicationActivities: nil)
                
                // Obtener la ventana actual para presentar el controlador
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    rootVC.present(activityVC, animated: true)
                }
            }) {
                HStack {
                    Spacer()
                    Text("INVITAR AMIGOS")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 10)
            }
            .frame(width:300, height: 40) // Establecer el tamaño específico del botón
            .background(Color.init(uiColor: UIColor(red: 239/255, green: 96/255, blue: 152/255, alpha: 1.0)))
            .cornerRadius(35)
            .padding(.vertical, 30)
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    ShareView()
}

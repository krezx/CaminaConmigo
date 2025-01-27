//
//  LoginView.swift
//  CaminaConmigo
//
//  Created by a on 21-01-25.
//


import SwiftUI

struct LoginView: View {
    @State private var mostrarLoginGoogle = false
    
    var body: some View {
        ZStack {
            // Esfera en el fondo (de color gris claro, ajusta según tu preferencia)
            Circle()
                .foregroundColor(Color.init(uiColor: UIColor(red: 239/255, green: 96/255, blue: 152/255, alpha: 1.0)))
                .frame(width: 700, height: 700) // Tamaño de la esfera
                .position(x: UIScreen.main.bounds.width / 2, y: -50) // Ubicación de la esfera

            // Contenido principal
            VStack(spacing: 20) {
                // Logo y Nombre de la App
                VStack(spacing: 42) {
                    Image("logo1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 288)
                    // Opciones de Inicio de Sesión
                    VStack(spacing: 14) {
                        Text("Iniciar Sesión")
                            .font(.system(size: 36, weight: .regular))
                            .foregroundColor(Color.black)
                            .padding(.bottom, 20)
                            
                        // Botón de Inicio de Sesión con Google
                        Button(action: {
                            mostrarLoginGoogle = true
                        }) {
                            HStack {
                                Image("logo_google")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24)
                                Text("Continuar con Google")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            .frame(width: 268)
                            .background(Color.init(uiColor: UIColor(red: 1, green: 124/255, blue: 31/255, alpha: 1.0)))
                            .cornerRadius(20)
                        }
                        
                        // Botón de Inicio como Invitado
                        Button(action: {
                            // Manejar inicio de sesión como invitado
                        }) {
                            HStack {
                                Spacer()
                                Text("Continuar como invitado")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.horizontal, 10) // Añadir algo de relleno horizontal para que el texto no quede pegado al borde
                        }
                        .frame(width: 231, height: 35) // Establecer el tamaño específico del botón
                        .background(Color.white)
                        .cornerRadius(35) // Redondear los bordes del botón para coincidir con el tamaño
                        .overlay(
                            RoundedRectangle(cornerRadius: 35) // Asegurar que el borde también sea redondeado
                                .stroke(Color.init(uiColor: UIColor(red: 239/255, green: 96/255, blue: 152/255, alpha: 1.0)), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
                .frame(width: 332, height: 470)
                .background(RoundedRectangle(cornerRadius: 30).stroke(Color.init(uiColor: UIColor(red: 239/255, green: 96/255, blue: 152/255, alpha: 1.0)), lineWidth: 2))
                .background(Color.white)
                .cornerRadius(30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

// Vista previa
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

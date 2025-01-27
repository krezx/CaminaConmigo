//
//  ProfileView.swift
//  CaminaConmigo
//
//  Created by a on 21-01-25.
//


import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Contenedor para la flecha y el contenido de la foto de perfil
                VStack {
                    HStack {
                        // Flecha de atrás en la parte superior izquierda
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.black)
                                .font(.title2)
                        }
                        .padding([.top, .leading], 20)
                        
                        Spacer()
                    }

                    // Contenido de la foto de perfil
                    VStack {
                        Image(systemName: "person.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                        
                        Text("Cambiar foto de perfil")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 239/255, green: 96/255, blue: 152/255))
                            .padding(.top, 5)
                    }
                }
                
                // Opciones del perfil
                VStack(spacing: 2) {
                    ProfileOption(title: "Nombre", value: "Pepe Contreras")
                    ProfileOption(title: "Nombre de usuario", value: "@pepe_468276ad")
                    ProfileOption(title: "Tipo de perfil", value: "Público")
                }
                .padding(.top, 20)
                
                // Información adicional
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.black)
                    Text("Miembro desde Enero 2025")
                        .font(.footnote)
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Alineación a la izquierda
                .padding(.top, 10)
                
                Spacer()
            }
            .padding(.horizontal)
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct ProfileOption: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title3)
                    .foregroundColor(.black)
                Text(value)
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

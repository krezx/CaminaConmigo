//
//  ConfigView.swift
//  CaminaConmigo
//
//  Created by a on 21-01-25.
//

import SwiftUI

struct ConfigView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var groupNotifications = true
    @State private var reportNotifications = false
    @State private var darkMode = false
    @State private var shakeEnabled = true
    
    var body: some View {
        NavigationView {
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
                    
                    Text("Configuración")
                        .font(.title)
                        .bold()
                    
                    Spacer() // Para balancear el espacio
                }
                .padding(5)
                .background(Color(UIColor.systemBackground))
                .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
                
                // Lista de configuraciones usando List
                List {
                    Toggle("Notificaciones de grupos", isOn: $groupNotifications)
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 5)

                    Toggle("Notificaciones de reporte", isOn: $reportNotifications)
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 5)

                    Toggle("Modo oscuro", isOn: $darkMode)
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 5)

                    Toggle("Shake", isOn: $shakeEnabled)
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 5)
                }
                .listStyle(PlainListStyle()) // Estilo plano para quitar la separación
            }
            .background(Color(UIColor.systemBackground))
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    ConfigView()
}

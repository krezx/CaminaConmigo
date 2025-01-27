//
//  SugerenciasView.swift
//  CaminaConmigo
//
//  Created by a on 20-01-25.
//

import SwiftUI

struct SugerenciasView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var nombre: String = ""
    @State private var numero: String = ""
    @State private var razon: String = ""
    @State private var mensaje: String = ""
    @State private var enviarAnonimo: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.title3)
                }
                .padding(.leading)
                
                Spacer()
                
                Text("Sugerencias")
                    .font(.title)
                    .bold()
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.clear)
                        .font(.title3)
                }
                .padding(.trailing)
            }
            .padding(.vertical, 5)
            .background(Color.white)
            .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
            
            Spacer(minLength: 16)
            
            VStack(spacing: 20){
                TextField("Nombre", text: $nombre)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                TextField("Numero", text: $numero)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .keyboardType(.numberPad)
                
                TextField("Razón", text: $razon)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                TextEditor(text: $mensaje)
                    .frame(height: 150)
                    .padding(8)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.clear, lineWidth: 1))
                    .overlay(
                        VStack {
                            if mensaje.isEmpty {
                                Text("Mensaje")
                                    .foregroundColor(.gray)
                            }
                        }
                    )
                
                HStack {
                    Toggle(isOn: $enviarAnonimo) {
                        Text("Enviar de forma Anónima")
                            .font(.subheadline)
                    }
                    .toggleStyle(CheckboxToggleStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                Button(action: {
                    // Acción del botón Enviar
                    print("Formulario enviado")
                }) {
                    Text("Enviar")
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color(red: 239/255, green: 96/255, blue: 152/255))
                        .cornerRadius(30)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .foregroundColor(configuration.isOn ? .pink : .gray)
                .onTapGesture { configuration.isOn.toggle() }
            configuration.label
        }
    }
}

#Preview {
    SugerenciasView()
}

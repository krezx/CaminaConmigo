//
//  SugerenciasView.swift
//  CaminaConmigo
//
//  Created by a on 20-01-25.
//

import SwiftUI

/// Vista que permite al usuario enviar sugerencias a través de un formulario con campos para nombre,
/// número, razón, mensaje y una opción de enviar de forma anónima.
struct SugerenciasView: View {
    @Environment(\.dismiss) private var dismiss  // Permite cerrar la vista cuando sea necesario.
    
    // Variables de estado para los campos del formulario.
    @State private var nombre: String = ""
    @State private var numero: String = ""
    @State private var razon: String = ""
    @State private var mensaje: String = ""
    @State private var enviarAnonimo: Bool = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let mailerService = MailerSendService()
    
    var body: some View {
        VStack(spacing: 0) {
            // Encabezado con botón de retroceso
            HStack {
                Button(action: {
                    dismiss()  // Cierra la vista cuando se presiona el botón.
                }) {
                    Image(systemName: "chevron.left")  // Icono de flecha hacia atrás.
                        .foregroundColor(.black)
                        .font(.title3)
                }
                .padding(.leading)
                
                Spacer()
                
                Text("Sugerencias")  // Título de la vista.
                    .font(.title)
                    .bold()
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "chevron.left")  // Espaciador invisible para equilibrar el diseño.
                        .foregroundColor(.clear)
                        .font(.title3)
                }
                .padding(.trailing)
            }
            .padding(.vertical, 5)
            .background(Color.white)
            .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)  // Sombra para el encabezado.
            
            Spacer(minLength: 16)  // Espacio entre el encabezado y el formulario.
            
            VStack(spacing: 20) {
                // Campos del formulario.
                TextField("Nombre", text: $nombre)  // Campo para el nombre.
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                TextField("Numero", text: $numero)  // Campo para el número.
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .keyboardType(.numberPad)  // Solo permite números en este campo.
                
                TextField("Razón", text: $razon)  // Campo para la razón de la sugerencia.
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                // Campo de texto para el mensaje.
                TextField("Mensaje...", text: $mensaje, axis: .vertical)  // Campo para el mensaje con múltiples líneas
                    .frame(height: 100, alignment: .top)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                // Opción de enviar de forma anónima.
                HStack {
                    Toggle(isOn: $enviarAnonimo) {
                        Text("Enviar de forma Anónima")
                            .font(.subheadline)
                    }
                    .toggleStyle(CustomCheckboxStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()  // Espacio antes del botón de envío.
                
                Button(action: {
                    Task {
                        await enviarSugerencia()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .tint(.white)
                    } else {
                        Text("Enviar")
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color(red: 239/255, green: 96/255, blue: 152/255))
                .cornerRadius(30)
                .padding(.horizontal)
                .disabled(isLoading)
            }
            .padding()  // Espaciado dentro del formulario.
        }
        .navigationBarHidden(true)  // Ocultar la barra de navegación.
        .toolbar(.hidden, for: .tabBar)  // Ocultar la barra de pestañas.
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Mensaje"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage.contains("éxito") {
                        dismiss()
                    }
                }
            )
        }
    }
    
    private func enviarSugerencia() async {
        isLoading = true
        do {
            try await mailerService.sendSuggestion(
                nombre: nombre,
                numero: numero,
                razon: razon,
                mensaje: mensaje,
                isAnonymous: enviarAnonimo
            )
            alertMessage = "Sugerencia enviada con éxito"
            showAlert = true
        } catch {
            alertMessage = "Error al enviar la sugerencia: \(error.localizedDescription)"
            showAlert = true
        }
        isLoading = false
    }
}

struct CustomCheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? Color(red: 239/255, green: 96/255, blue: 152/255) : .gray)
                .font(.system(size: 20))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
}
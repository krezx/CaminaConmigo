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
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SugerenciasViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Encabezado con botón de retroceso
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
            
            ScrollView {
                VStack(spacing: 20) {
                    TextField("Nombre", text: $viewModel.nombre)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    
                    TextField("Numero", text: $viewModel.numero)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .keyboardType(.numberPad)
                    
                    TextField("Razón", text: $viewModel.razon)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    
                    TextField("Mensaje...", text: $viewModel.mensaje, axis: .vertical)
                        .frame(height: 100, alignment: .top)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    
                    HStack {
                        Toggle(isOn: $viewModel.enviarAnonimo) {
                            Text("Enviar de forma Anónima")
                                .font(.subheadline)
                        }
                        .toggleStyle(CustomCheckboxStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await viewModel.enviarSugerencia()
                        }
                    }) {
                        if viewModel.isLoading {
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
                    .disabled(viewModel.isLoading)
                }
                .padding()
            }
            .background(Color.white)
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        hideKeyboard()
                    }
            )
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Mensaje"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK")) {
                    if viewModel.alertMessage.contains("éxito") {
                        dismiss()
                    }
                }
            )
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
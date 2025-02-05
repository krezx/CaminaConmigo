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
    @StateObject private var viewModel = NotificationsViewModel()
    @State private var showAlert = false
    @State private var alertMessage = ""
    
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
            
            // Contenido principal
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Sección de solicitudes de amistad
                    if !viewModel.friendRequests.isEmpty {
                        Section {
                            ForEach(viewModel.friendRequests) { request in
                                FriendRequestNotificationRow(request: request, viewModel: viewModel)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                            }
                        } header: {
                            Text("Solicitudes de amistad")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)  // Oculta la barra de navegación de la vista.
        .toolbar(.hidden, for: .tabBar)  // Oculta la barra de pestañas (tab bar).
        .alert("Resultado", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}

struct FriendRequestNotificationRow: View {
    let request: FriendRequest
    let viewModel: NotificationsViewModel
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(request.fromUserName.prefix(1)).uppercased())
                        .font(.title2)
                        .foregroundColor(.blue)
                )
            
            // Información
            VStack(alignment: .leading, spacing: 4) {
                Text(request.fromUserName)
                    .font(.headline)
                Text(request.fromUserEmail)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Botones de acción
            if isLoading {
                ProgressView()
            } else {
                HStack(spacing: 12) {
                    Button(action: { handleRequest(accept: true) }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                    
                    Button(action: { handleRequest(accept: false) }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func handleRequest(accept: Bool) {
        isLoading = true
        Task {
            do {
                try await viewModel.handleFriendRequest(request, accept: accept)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                isLoading = false
            }
        }
    }
}

/// Vista previa para previsualizar la vista de notificaciones en el canvas de Xcode.
struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()  // Previsualización de la vista de notificaciones.
    }
}

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
    @StateObject private var friendsViewModel = FriendsViewModel()
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            // Barra superior
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
            .padding(.horizontal)
            .background(Color.white)
            .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Sección de solicitudes de amistad pendientes
                    if !viewModel.friendRequests.isEmpty {
                        Section {
                            ForEach(viewModel.friendRequests) { request in
                                FriendRequestRow(request: request, viewModel: friendsViewModel)
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
                    
                    // Sección de notificaciones generales
                    if !viewModel.notifications.isEmpty {
                        Section {
                            ForEach(viewModel.notifications) { notification in
                                NotificationRow(notification: notification, viewModel: viewModel)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .onAppear {
                                        if !notification.isRead {
                                            viewModel.markNotificationAsRead(notification)
                                        }
                                    }
                            }
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
    let viewModel: FriendsViewModel
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

struct NotificationRow: View {
    let notification: UserNotification
    let viewModel: NotificationsViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(notification.isRead ? Color.gray.opacity(0.2) : Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: iconForType(notification.type))
                        .foregroundColor(notification.isRead ? .gray : .blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)
                    .foregroundColor(notification.isRead ? .gray : .primary)
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .opacity(notification.isRead ? 0.8 : 1)
    }
    
    private func iconForType(_ type: UserNotification.NotificationType) -> String {
        switch type {
        case .friendRequest:
            return "person.crop.circle.badge.plus"
        case .friendRequestAccepted:
            return "person.2.circle.fill"
        case .emergencyAlert:
            return "exclamationmark.triangle.fill"
        case .newReport:
            return "doc.text.fill"
        case .reportComment:
            return "text.bubble.fill"
        case .groupInvite:
            return "person.3.fill"
        }
    }
}

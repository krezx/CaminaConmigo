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
                    // Lista de solicitudes pendientes
                    if !friendsViewModel.friendRequests.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Solicitudes pendientes")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(friendsViewModel.friendRequests) { request in
                                FriendRequestRow(request: request, viewModel: friendsViewModel)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                Divider()
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    // Sección de notificaciones generales
                    if !viewModel.notifications.isEmpty {
                        VStack(alignment: .leading) {
                            ForEach(viewModel.notifications) { notification in
                                NotificationRow(notification: notification, viewModel: viewModel)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                Divider()
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
        .onAppear {
            friendsViewModel.loadFriendRequests()
        }
    }
}

struct NotificationRow: View {
    let notification: UserNotification
    let viewModel: NotificationsViewModel
    @State private var navigateToChat: Bool = false
    
    var body: some View {
        NavigationLink(destination: destinationView, isActive: $navigateToChat) {
            HStack(spacing: 12) {
                Circle()
                    .fill(notification.isRead ? Color.gray.opacity(0.2) : Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: iconForType(notification.type))
                            .foregroundColor(notification.isRead ? .gray : .blue)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(notification.title)
                            .font(.headline)
                            .foregroundColor(notification.isRead ? .gray : .primary)
                        Spacer()
                        Text(timeAgoDisplay(date: notification.createdAt))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Text(notification.message)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .opacity(notification.isRead ? 0.8 : 1)
            .contentShape(Rectangle())
            .onTapGesture {
                handleNotificationTap()
            }
        }
    }
    
    private func timeAgoDisplay(date: Date) -> String {
        let seconds = -date.timeIntervalSinceNow
        
        let minute = 60.0
        let hour = minute * 60
        let day = hour * 24
        let week = day * 7
        let month = day * 30
        let year = day * 365
        
        switch seconds {
        case 0..<minute:
            return "hace un momento"
        case minute..<hour:
            let minutes = Int(seconds/minute)
            return "hace \(minutes) \(minutes == 1 ? "minuto" : "minutos")"
        case hour..<day:
            let hours = Int(seconds/hour)
            return "hace \(hours) \(hours == 1 ? "hora" : "horas")"
        case day..<week:
            let days = Int(seconds/day)
            return "hace \(days) \(days == 1 ? "día" : "días")"
        case week..<month:
            let weeks = Int(seconds/week)
            return "hace \(weeks) \(weeks == 1 ? "semana" : "semanas")"
        case month..<year:
            let months = Int(seconds/month)
            return "hace \(months) \(months == 1 ? "mes" : "meses")"
        default:
            let years = Int(seconds/year)
            return "hace \(years) \(years == 1 ? "año" : "años")"
        }
    }
    
    private var destinationView: some View {
        Group {
            if notification.type == .groupInvite,
               let chatId = notification.data["chatId"] {
                ChatDetailView(chat: Chat(
                    id: chatId,
                    participants: [], // Se cargarán los datos completos al abrir el chat
                    name: notification.data["groupName"] ?? "Grupo",
                    lastMessage: "",
                    timeString: "",
                    lastMessageTimestamp: Date(),
                    adminIds: []
                ))
            } else {
                EmptyView()
            }
        }
    }
    
    private func handleNotificationTap() {
        if !notification.isRead {
            viewModel.markNotificationAsRead(notification)
        }
        
        if notification.type == .groupInvite,
           let chatId = notification.data["chatId"] {
            navigateToChat = true
        }
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

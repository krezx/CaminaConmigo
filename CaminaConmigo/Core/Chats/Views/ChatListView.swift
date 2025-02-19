//
//  ChatListView.swift
//  CaminaConmigo
//
//  Created by a on 22-01-25.
//

import SwiftUI // Importa el framework SwiftUI para construir la interfaz de usuario.
import FirebaseAuth
import FirebaseFirestore

/// Vista principal que muestra una lista de chats disponibles.
struct ChatListView: View {
    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var friendsViewModel = FriendsViewModel()
    @State private var showAddFriend = false
    
    private var friendsWithoutChat: [UserProfile] {
        // Filtramos los amigos que no tienen un chat activo
        friendsViewModel.friends.filter { friend in
            !viewModel.chats.contains { chat in
                chat.participants.contains(friend.id)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header personalizado para la vista de chats
                VStack {
                    Text("Chats") // Título de la sección
                        .font(.title)
                        .bold()
                        .padding(.vertical, 5)
                }
                .frame(maxWidth: .infinity)
                .background(Color.customBackground)
                .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2) // Estilo de sombra para el encabezado
                
                // Lista de chats en forma de desplazamiento
                ScrollView {
                    VStack(spacing: 0) {
                        ChatHeaderButtons(showAddFriend: $showAddFriend)
                            .padding(.horizontal)
                        
                        if viewModel.isLoading || friendsViewModel.isLoading {
                            ProgressView()
                                .padding()
                        } else {
                            // Chats activos
                            if !viewModel.chats.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Chats activos")
                                        .font(.headline)
                                        .padding(.horizontal)
                                        .padding(.top)
                                    
                                    LazyVStack(spacing: 0) {
                                        ForEach(viewModel.chats) { chat in
                                            ChatRowView(chat: chat)
                                                .padding(.horizontal)
                                            Divider()
                                        }
                                    }
                                }
                            }
                            
                            if viewModel.chats.isEmpty && friendsWithoutChat.isEmpty {
                                Text("No tienes chats activos ni amigos agregados")
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true) // Oculta la barra de navegación de la vista
        .sheet(isPresented: $showAddFriend) {
            AddFriendView()
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil || friendsViewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
                friendsViewModel.error = nil
            }
        } message: {
            if let error = viewModel.error ?? friendsViewModel.error {
                Text(error)
            }
        }
        .onAppear {
            viewModel.listenToChats()
            friendsViewModel.loadFriends()
        }
    }
}

/// Vista que representa los botones en el encabezado de la lista de chats. Los botones permiten añadir amigos o crear grupos.
struct ChatHeaderButtons: View {
    @Binding var showAddFriend: Bool
    @State private var showCreateGroup = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Botón para añadir un amigo
            Button(action: { showAddFriend = true }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Añadir Amigo")
                }
            }
            
            // Botón para crear un grupo
            Button(action: { showCreateGroup = true }) {
                HStack {
                    Image(systemName: "person.3")
                    Text("Crear Grupo")
                }
            }
        }
        .padding(.vertical, 15)
        .sheet(isPresented: $showCreateGroup) {
            CreateGroupView()
        }
    }
}

/// Vista que representa una fila individual de chat. Esta vista incluye información sobre el chat, como el nombre, el último mensaje y la hora.
struct ChatRowView: View {
    let chat: Chat // El chat que se mostrará en la fila
    @State private var friendNickname: String?
    
    var displayName: String {
        if chat.participants.count == 2,
           let currentUserId = Auth.auth().currentUser?.uid,
           let _ = chat.participants.first(where: { $0 != currentUserId }) {
            return friendNickname ?? chat.name
        }
        return chat.name
    }
    
    var body: some View {
        NavigationLink(destination: ChatDetailView(chat: chat)) {
            HStack(spacing: 12) {
                // Imagen de perfil del chat (simulada aquí con un círculo gris)
                if chat.participants.count == 2,
                   let currentUserId = Auth.auth().currentUser?.uid,
                   let otherUserId = chat.participants.first(where: { $0 != currentUserId }) {
                    ProfileImageView(userId: otherUserId, size: 50)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        // Nombre del chat
                        Text(displayName)
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        
                        // Mostrar contador de mensajes sin leer
                        if chat.unreadCount > 0 {
                            Text("\(chat.unreadCount)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        
                        Text(chat.timeString)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    // Último mensaje del chat
                    Text(chat.lastMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            // Cargar el nickname al aparecer la vista
            if chat.participants.count == 2,
               let currentUserId = Auth.auth().currentUser?.uid,
               let otherUserId = chat.participants.first(where: { $0 != currentUserId }) {
                Task {
                    do {
                        let snapshot = try await Firestore.firestore()
                            .collection("users")
                            .document(currentUserId)
                            .collection("friends")
                            .document(otherUserId)
                            .getDocument()
                        
                        if let nickname = snapshot.data()?["nickname"] as? String {
                            DispatchQueue.main.async {
                                self.friendNickname = nickname
                            }
                        }
                    } catch {
                        print("Error al cargar el nickname: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

struct ProfileImageView: View {
    let userId: String
    let size: CGFloat
    @State private var photoURL: String?
    
    var body: some View {
        Group {
            if let photoURL = photoURL, let url = URL(string: photoURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .onAppear {
            loadProfilePhoto()
        }
    }
    
    private func loadProfilePhoto() {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let photoURL = data["photoURL"] as? String {
                DispatchQueue.main.async {
                    self.photoURL = photoURL
                }
            }
        }
    }
}

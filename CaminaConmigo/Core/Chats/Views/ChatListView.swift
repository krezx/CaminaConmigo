//
//  ChatListView.swift
//  CaminaConmigo
//
//  Created by a on 22-01-25.
//

import SwiftUI // Importa el framework SwiftUI para construir la interfaz de usuario.

/// Vista principal que muestra una lista de chats disponibles.
struct ChatListView: View {
    @StateObject private var friendsViewModel = FriendsViewModel()
    @State private var showAddFriend = false
    
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
                .background(Color.white)
                .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2) // Estilo de sombra para el encabezado
                
                // Lista de chats en forma de desplazamiento
                ScrollView {
                    VStack(spacing: 0) {
                        ChatHeaderButtons(showAddFriend: $showAddFriend)
                            .padding(.horizontal)
                        
                        if friendsViewModel.isLoading {
                            ProgressView()
                                .padding()
                        } else if friendsViewModel.friends.isEmpty {
                            Text("No tienes amigos agregados aún")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            LazyVStack(spacing: 0) {
                                ForEach(friendsViewModel.friends, id: \.id) { friend in
                                    ChatRowView(chat: Chat(
                                        name: friend.name,
                                        lastMessage: "Toca para iniciar una conversación",
                                        timeString: ""
                                    ))
                                    .padding(.horizontal)
                                    Divider()
                                }
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
        .alert("Error", isPresented: .constant(friendsViewModel.error != nil)) {
            Button("OK") {
                friendsViewModel.error = nil
            }
        } message: {
            if let error = friendsViewModel.error {
                Text(error)
            }
        }
    }
}

/// Vista que representa los botones en el encabezado de la lista de chats. Los botones permiten añadir amigos o crear grupos.
struct ChatHeaderButtons: View {
    @Binding var showAddFriend: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            // Botón para añadir un amigo
            Button(action: { showAddFriend = true }) {
                HStack {
                    Image(systemName: "person.badge.plus") // Icono de añadir amigo
                    Text("Añadir Amigo")
                }
            }
            
            // Botón para crear un grupo
            Button(action: {}) {
                HStack {
                    Image(systemName: "person.3") // Icono de grupo
                    Text("Crear Grupo")
                }
            }
        }
        .padding(.vertical, 15) // Añade espacio vertical entre los botones
    }
}

/// Vista que representa una fila individual de chat. Esta vista incluye información sobre el chat, como el nombre, el último mensaje y la hora.
struct ChatRowView: View {
    let chat: Chat // El chat que se mostrará en la fila
    
    var body: some View {
        NavigationLink(destination: ChatDetailView(chat: chat)) { // Al hacer clic, se navega a la vista de detalles del chat
            HStack(spacing: 12) {
                // Imagen de perfil del chat (simulada aquí con un círculo gris)
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        // Nombre del chat
                        Text(chat.name)
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        // Hora del último mensaje
                        Text(chat.timeString)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    // Último mensaje del chat
                    Text(chat.lastMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(1) // Limita el texto a una sola línea
                }
            }
            .padding(.vertical, 8) // Añade espacio vertical a la fila
        }
        .buttonStyle(PlainButtonStyle()) // Estilo plano para el botón de la fila (sin cambios visuales)
    }
}

/// Estructura que representa un chat individual. Implementa `Identifiable` para que pueda ser utilizado en una lista.
struct Chat: Identifiable {
    let id = UUID() // ID único para el chat
    let name: String // Nombre del chat
    let lastMessage: String // Último mensaje enviado
    let timeString: String // Hora del último mensaje
}

/// Datos de ejemplo para mostrar en la lista de chats.
let sampleChats = [
    Chat(name: "John Doe", lastMessage: "Tu: Ya llegué a mi destino amiga", timeString: "10 min"),
    Chat(name: "Jane Doe", lastMessage: "Avísame si saldrás hoy", timeString: "10 min"),
    Chat(name: "Familia", lastMessage: "Papá: Ya llegaron??", timeString: "33 min"),
    Chat(name: "Name", lastMessage: "Supporting line text lorem ipsum dolor...", timeString: "10 min"),
]

/// Vista previa para mostrar la vista en el canvas de Xcode.
struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView() // Vista previa de ChatListView
    }
}

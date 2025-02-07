//
//  ChatDetailView.swift
//  CaminaConmigo
//
//  Created by a on 24-01-25.
//

import SwiftUI // Importa el framework SwiftUI para la construcción de la interfaz de usuario.
import FirebaseAuth
import FirebaseFirestore

/// Vista que muestra los detalles de un chat, incluyendo el encabezado del chat, los mensajes y el campo de entrada de mensajes.
struct ChatDetailView: View {
    let chat: Chat // El chat que se va a mostrar.
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText: String = "" // El texto del mensaje que se está escribiendo en el campo de entrada.
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            // Header del chat
            ChatHeader(chat: chat, presentationMode: presentationMode)
            
            // Vista de los mensajes
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // Campo de entrada de mensaje
            MessageInputField(messageText: $messageText) {
                if !messageText.isEmpty {
                    viewModel.sendMessage(messageText, in: chat.id)
                    messageText = ""
                }
            }
        }
        .navigationBarHidden(true) // Oculta la barra de navegación.
        .onAppear {
            viewModel.listenToMessages(in: chat.id)
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error)
            }
        }
    }
}

/// Vista que representa el encabezado del chat, que incluye el nombre del chat y un botón para volver atrás.
struct ChatHeader: View {
    let chat: Chat
    let presentationMode: Binding<PresentationMode>
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var friendsViewModel = FriendsViewModel()
    @State private var showNicknameDialog = false
    @State private var newNickname = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var friendNickname: String?

    private var displayName: String {
        if chat.participants.count == 2,
           let currentUserId = Auth.auth().currentUser?.uid,
           let otherUserId = chat.participants.first(where: { $0 != currentUserId }) {
            return friendNickname ?? chat.name
        }
        return chat.name
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(Color.black)
            }
            
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
            
            Text(displayName)
                .lineLimit(1)
                .font(.title)
                .bold()
                .padding(.vertical, 5)
            
            Spacer()
            
            // Íconos de ubicación y ondas
            VStack {
                ZStack {
                    Image(systemName: "location")
                        .font(.caption)
                    Image(systemName: "wave.3.left")
                        .font(.caption)
                        .offset(x: -12, y: 0)
                    Image(systemName: "wave.3.right")
                        .font(.caption)
                        .offset(x: 12, y: 0)
                }
            }
            .padding(.trailing, 8)
            
            // Menú de opciones
            Menu {
                // Solo mostrar la opción de cambiar apodo si es un chat individual
                if chat.participants.count == 2 {
                    Button(action: {
                        showNicknameDialog = true
                    }) {
                        Label("Cambiar apodo", systemImage: "pencil")
                    }
                }
                
                Button(action: {
                    // Acción para eliminar chat (por implementar)
                }) {
                    Label("Eliminar chat", systemImage: "trash")
                        .foregroundColor(.red)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 22))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal)
        .background(Color.white)
        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
        .alert("Cambiar apodo", isPresented: $showNicknameDialog) {
            TextField("Nuevo apodo", text: $newNickname)
            
            Button("Cancelar", role: .cancel) {
                newNickname = ""
            }
            
            Button("Guardar") {
                if !newNickname.isEmpty {
                    // Obtener el ID del otro usuario
                    if let otherUserId = chat.participants.first(where: { $0 != Auth.auth().currentUser?.uid }) {
                        Task {
                            do {
                                try await friendsViewModel.updateFriendNickname(friendId: otherUserId, newNickname: newNickname)
                                friendNickname = newNickname // Actualizar el nickname localmente
                                alertMessage = "Apodo actualizado con éxito"
                            } catch {
                                alertMessage = "Error al actualizar el apodo: \(error.localizedDescription)"
                            }
                            showAlert = true
                            newNickname = ""
                        }
                    }
                }
            }
        }
        .alert("Mensaje", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
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

/// Vista que representa una burbuja de mensaje, que muestra el contenido del mensaje y su estilo según el emisor.
struct MessageBubble: View {
    let message: Message // El mensaje que se va a mostrar.
    
    private var isFromCurrentUser: Bool {
        message.senderId == Auth.auth().currentUser?.uid
    }
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer() // Añade espacio si el mensaje es del usuario actual.
            }

            VStack(alignment: isFromCurrentUser ? .trailing : .leading) {
                Text(message.content)
                    .padding(12)
                    .background(isFromCurrentUser ? Color.blue : Color(UIColor.systemGray5)) // El color de la burbuja depende de si el mensaje es del usuario actual.
                    .foregroundColor(isFromCurrentUser ? .white : .black) // El color del texto depende de si es del usuario actual.
                    .cornerRadius(16)
                
                Text(DateFormatter.localizedString(from: message.timestamp, dateStyle: .none, timeStyle: .short))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !isFromCurrentUser {
                Spacer() // Añade espacio si el mensaje no es del usuario actual.
            }
        }
    }
}

/// Vista que representa el campo de entrada donde el usuario puede escribir un mensaje.
struct MessageInputField: View {
    @Binding var messageText: String // El texto del mensaje que se está escribiendo (vinculado a la vista de ChatDetailView).
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Campo de texto donde el usuario escribe el mensaje
            TextField("Escribe un mensaje...", text: $messageText)
                .padding(12)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
            
            // Botón para enviar el mensaje (actualmente no tiene funcionalidad implementada)
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill") // Icono de flecha hacia arriba
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
    }
}

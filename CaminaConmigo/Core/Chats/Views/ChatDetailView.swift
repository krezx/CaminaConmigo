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
    @State var chat: Chat // Cambiado a @State
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText: String = "" 
    @State private var isLoadingChat: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            if isLoadingChat {
                ProgressView()
            } else {
                // Header del chat
                ChatHeader(chat: chat, presentationMode: presentationMode)
                
                // Vista de los mensajes
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message, chat: chat)
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
        }
        .navigationBarHidden(true) // Oculta la barra de navegación.
        .onAppear {
            if chat.participants.isEmpty {
                // Si el chat se abrió desde una notificación, cargar los datos completos
                loadFullChatData()
            }
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
    
    private func loadFullChatData() {
        isLoadingChat = true
        Task {
            if let updatedChat = await viewModel.loadChatById(chat.id) {
                DispatchQueue.main.async {
                    chat = updatedChat // Ahora podemos modificar chat porque es @State
                    isLoadingChat = false
                }
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
    @State private var showGroupNameDialog = false
    @State private var showAdminActionSheet = false
    @State private var showAddParticipantsSheet = false
    @State private var selectedUserId: String?
    @State private var selectedFriends: Set<String> = []
    @State private var newNickname = ""
    @State private var newGroupName = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var friendNickname: String?
    @State private var originalUsername: String?
    @State private var participantNames: [String: String] = [:]  // [userId: nombre]
    @State private var availableFriends: [UserProfile] = []
    @State private var showLocationSharingAlert = false
    @State private var isShareingLocation = false

    private var isAdmin: Bool {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return false }
        return chat.adminIds.contains(currentUserId)
    }

    private var displayName: String {
        if chat.participants.count == 2,
           let currentUserId = Auth.auth().currentUser?.uid,
           let _ = chat.participants.first(where: { $0 != currentUserId }) {
            return friendNickname ?? chat.name
        }
        return chat.name
    }

    private func loadParticipantNames() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        for userId in chat.participants where userId != currentUserId {
            do {
                // Primero intentar obtener el nickname si es amigo
                let friendDoc = try await db.collection("users")
                    .document(currentUserId)
                    .collection("friends")
                    .document(userId)
                    .getDocument()
                
                if let nickname = friendDoc.data()?["nickname"] as? String {
                    DispatchQueue.main.async {
                        participantNames[userId] = nickname
                    }
                } else {
                    // Si no es amigo o no tiene nickname, obtener el username
                    let userDoc = try await db.collection("users")
                        .document(userId)
                        .getDocument()
                    
                    if let username = userDoc.data()?["username"] as? String {
                        DispatchQueue.main.async {
                            participantNames[userId] = "@\(username)"
                        }
                    }
                }
            } catch {
                print("Error al cargar nombre del participante: \(error.localizedDescription)")
            }
        }
    }

    private func loadAvailableFriends() {
        Task {
            do {
                // Usar loadFriends en lugar de loadFriendsAsync
                friendsViewModel.loadFriends()
                
                // Esperar a que se carguen los amigos
                try await Task.sleep(nanoseconds: 1_000_000_000)  // Esperar 1 segundo
                
                DispatchQueue.main.async {
                    self.availableFriends = friendsViewModel.friends.filter { !chat.participants.contains($0.id) }
                }
            } catch {
                print("Error al cargar amigos: \(error.localizedDescription)")
            }
        }
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
            Button(action: {
                showLocationSharingAlert = true
            }) {
                VStack {
                    ZStack {
                        Image(systemName: "location")
                            .font(.caption)
                            .foregroundColor(isShareingLocation ? .blue : .black)
                        Image(systemName: "wave.3.left")
                            .font(.caption)
                            .foregroundColor(isShareingLocation ? .blue : .black)
                            .offset(x: -12, y: 0)
                        Image(systemName: "wave.3.right")
                            .font(.caption)
                            .foregroundColor(isShareingLocation ? .blue : .black)
                            .offset(x: 12, y: 0)
                    }
                }
                .padding(.trailing, 8)
            }
            
            // Menú de opciones
            Menu {
                // Mostrar el nombre de usuario original si existe un apodo diferente
                if let originalUsername = originalUsername,
                   let nickname = friendNickname,
                   originalUsername != nickname {
                    Text("Usuario: @\(originalUsername)")
                        .foregroundColor(.gray)
                }
                
                // Solo mostrar la opción de cambiar apodo si es un chat individual
                if chat.participants.count == 2 {
                    Button(action: {
                        showNicknameDialog = true
                    }) {
                        Label("Cambiar apodo", systemImage: "pencil")
                    }
                }
                
                // Opciones de grupo (solo para administradores)
                if chat.participants.count > 2 && isAdmin {
                    Button(action: {
                        showGroupNameDialog = true
                    }) {
                        Label("Editar nombre del grupo", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        selectedFriends.removeAll()
                        loadAvailableFriends()
                        showAddParticipantsSheet = true
                    }) {
                        Label("Añadir participantes", systemImage: "person.badge.plus")
                    }
                    
                    Menu("Administrar miembros") {
                        ForEach(chat.participants, id: \.self) { userId in
                            if userId != Auth.auth().currentUser?.uid {
                                Button(action: {
                                    selectedUserId = userId
                                    showAdminActionSheet = true
                                }) {
                                    Label(
                                        chat.adminIds.contains(userId) ? 
                                            "👑 \(participantNames[userId] ?? "Usuario") (Admin)" : 
                                            participantNames[userId] ?? "Usuario",
                                        systemImage: "person"
                                    )
                                }
                            }
                        }
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
        .alert("Editar nombre del grupo", isPresented: $showGroupNameDialog) {
            TextField("Nuevo nombre", text: $newGroupName)
            
            Button("Cancelar", role: .cancel) {
                newGroupName = ""
            }
            
            Button("Guardar") {
                if !newGroupName.isEmpty {
                    Task {
                        do {
                            try await chatViewModel.updateGroupName(chatId: chat.id, newName: newGroupName)
                            alertMessage = "Nombre del grupo actualizado con éxito"
                        } catch {
                            alertMessage = "Error al actualizar el nombre: \(error.localizedDescription)"
                        }
                        showAlert = true
                        newGroupName = ""
                    }
                }
            }
        }
        .alert("Mensaje", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .confirmationDialog("Acciones de administrador", isPresented: $showAdminActionSheet, titleVisibility: .visible) {
            if let userId = selectedUserId {
                if chat.adminIds.contains(userId) {
                    Button("Remover como administrador", role: .destructive) {
                        Task {
                            do {
                                try await chatViewModel.removeAdmin(chatId: chat.id, userId: userId)
                                alertMessage = "Administrador removido con éxito"
                            } catch {
                                alertMessage = error.localizedDescription
                            }
                            showAlert = true
                        }
                    }
                } else {
                    Button("Hacer administrador") {
                        Task {
                            do {
                                try await chatViewModel.addAdmin(chatId: chat.id, userId: userId)
                                alertMessage = "Administrador agregado con éxito"
                            } catch {
                                alertMessage = error.localizedDescription
                            }
                            showAlert = true
                        }
                    }
                }
                
                Button("Cancelar", role: .cancel) {
                    selectedUserId = nil
                }
            }
        }
        .sheet(isPresented: $showAddParticipantsSheet) {
            NavigationView {
                List {
                    ForEach(availableFriends) { friend in
                        Button(action: {
                            if selectedFriends.contains(friend.id) {
                                selectedFriends.remove(friend.id)
                            } else {
                                selectedFriends.insert(friend.id)
                            }
                        }) {
                            HStack {
                                Text(friend.name)
                                Spacer()
                                if selectedFriends.contains(friend.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Añadir participantes")
                .navigationBarItems(
                    leading: Button("Cancelar") {
                        showAddParticipantsSheet = false
                    },
                    trailing: Button("Añadir") {
                        Task {
                            do {
                                try await chatViewModel.addParticipants(
                                    chatId: chat.id,
                                    newParticipants: Array(selectedFriends)
                                )
                                alertMessage = "Participantes añadidos con éxito"
                            } catch {
                                alertMessage = error.localizedDescription
                            }
                            showAlert = true
                            showAddParticipantsSheet = false
                        }
                    }
                    .disabled(selectedFriends.isEmpty)
                )
            }
        }
        .alert("Compartir ubicación", isPresented: $showLocationSharingAlert) {
            Button(isShareingLocation ? "Dejar de compartir" : "Compartir", role: isShareingLocation ? .destructive : .none) {
                isShareingLocation.toggle()
                // Aquí implementarías la lógica para comenzar/detener el compartir ubicación
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text(isShareingLocation ? 
                "¿Deseas dejar de compartir tu ubicación actual?" :
                "¿Deseas compartir tu ubicación actual? Se compartirá hasta que decidas detenerla.")
        }
        .onAppear {
            // Cargar nombres de participantes
            Task {
                await loadParticipantNames()
            }
            
            // Cargar el nickname y username al aparecer la vista
            if chat.participants.count == 2,
               let currentUserId = Auth.auth().currentUser?.uid,
               let otherUserId = chat.participants.first(where: { $0 != currentUserId }) {
                
                // Cargar el nickname
                Task {
                    do {
                        let friendSnapshot = try await Firestore.firestore()
                            .collection("users")
                            .document(currentUserId)
                            .collection("friends")
                            .document(otherUserId)
                            .getDocument()
                        
                        if let nickname = friendSnapshot.data()?["nickname"] as? String {
                            DispatchQueue.main.async {
                                self.friendNickname = nickname
                            }
                        }
                        
                        // Cargar el username original
                        let userSnapshot = try await Firestore.firestore()
                            .collection("users")
                            .document(otherUserId)
                            .getDocument()
                        
                        if let username = userSnapshot.data()?["username"] as? String {
                            DispatchQueue.main.async {
                                self.originalUsername = username
                            }
                        }
                    } catch {
                        print("Error al cargar el nickname o username: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

/// Vista que representa una burbuja de mensaje, que muestra el contenido del mensaje y su estilo según el emisor.
struct MessageBubble: View {
    let message: Message
    let chat: Chat // Añadimos referencia al chat
    @StateObject private var friendsViewModel = FriendsViewModel()
    @State private var senderName: String = ""
    
    private var isFromCurrentUser: Bool {
        message.senderId == Auth.auth().currentUser?.uid
    }
    
    var body: some View {
        VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
            // Mostrar el nombre del remitente solo si:
            // 1. Es un chat grupal (más de 2 participantes)
            // 2. No es un mensaje propio
            if chat.participants.count > 2 && !isFromCurrentUser {
                Text(senderName)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }
            
            Text(message.content)
                .padding(12)
                .background(isFromCurrentUser ? Color.blue : Color(UIColor.systemGray5))
                .foregroundColor(isFromCurrentUser ? .white : .black)
                .cornerRadius(16)
            
            Text(DateFormatter.localizedString(from: message.timestamp, dateStyle: .none, timeStyle: .short))
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: isFromCurrentUser ? .trailing : .leading)
        .onAppear {
            loadSenderName()
        }
    }
    
    private func loadSenderName() {
        guard !isFromCurrentUser && chat.participants.count > 2 else { return }
        
        // Primero intentamos obtener el nickname si es un amigo
        if let currentUserId = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            
            // Verificar si el remitente es amigo y obtener su nickname
            db.collection("users")
                .document(currentUserId)
                .collection("friends")
                .document(message.senderId)
                .getDocument { snapshot, error in
                    if let nickname = snapshot?.data()?["nickname"] as? String {
                        self.senderName = nickname
                    } else {
                        // Si no es amigo o no tiene nickname, obtener el username
                        db.collection("users")
                            .document(message.senderId)
                            .getDocument { snapshot, error in
                                if let username = snapshot?.data()?["username"] as? String {
                                    self.senderName = username
                                }
                            }
                    }
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

import SwiftUI
import FirebaseAuth

struct CreateGroupView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var friendsViewModel = FriendsViewModel()
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var groupName = ""
    @State private var selectedFriends: Set<String> = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Campo de nombre del grupo
                TextField("Nombre del grupo", text: $groupName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Lista de amigos
                List {
                    ForEach(friendsViewModel.friends) { friend in
                        FriendSelectionRow(
                            friend: friend,
                            isSelected: selectedFriends.contains(friend.id)
                        ) {
                            if selectedFriends.contains(friend.id) {
                                selectedFriends.remove(friend.id)
                            } else {
                                selectedFriends.insert(friend.id)
                            }
                        }
                    }
                }
                
                // Botón de crear grupo
                Button(action: createGroup) {
                    Text("Crear Grupo")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(groupName.isEmpty || selectedFriends.count < 2 ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(groupName.isEmpty || selectedFriends.count < 2)
                .padding(.horizontal)
                
                // Texto de ayuda
                if groupName.isEmpty || selectedFriends.count < 2 {
                    Text(groupName.isEmpty ? "Ingresa un nombre para el grupo" : selectedFriends.count < 2 ? "Selecciona al menos 2 amigos" : "")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Crear Grupo")
            .navigationBarItems(leading: Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Mensaje"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if alertMessage.contains("creado con éxito") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
            .onAppear {
                friendsViewModel.loadFriends()
            }
        }
    }
    
    private func createGroup() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        if selectedFriends.count < 2 {
            alertMessage = "Selecciona al menos 2 amigos para crear un grupo"
            showAlert = true
            return
        }
        
        if groupName.isEmpty {
            alertMessage = "Por favor, ingresa un nombre para el grupo"
            showAlert = true
            return
        }
        
        var participants = Array(selectedFriends)
        participants.append(currentUserId)
        
        chatViewModel.createGroupChat(name: groupName, participants: participants) { success in
            if success {
                alertMessage = "Grupo creado con éxito"
            } else {
                alertMessage = "Error al crear el grupo"
            }
            showAlert = true
        }
    }
}

struct FriendSelectionRow: View {
    let friend: UserProfile
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                Text(friend.name)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
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
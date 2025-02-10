import SwiftUI

struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = FriendsViewModel()
    @State private var searchText = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Añadir Amigo")
                    .font(.title)
                    .padding(.top)
                
                Text("Ingresa el email o username de tu amigo")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("Email o username", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .padding(.horizontal)
                
                Button(action: sendFriendRequest) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Enviar Solicitud")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(searchText.isEmpty || viewModel.isLoading)
                
                // Lista de solicitudes pendientes
                if !viewModel.friendRequests.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Solicitudes pendientes")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        List(viewModel.friendRequests) { request in
                            FriendRequestRow(request: request, viewModel: viewModel)
                        }
                    }
                }
                
                Spacer()
            }
            .alert("Resultado", isPresented: $showAlert) {
                Button("OK") {
                    if !alertMessage.contains("error") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func sendFriendRequest() {
        Task {
            do {
                try await viewModel.sendFriendRequest(searchText: searchText)
                alertMessage = "Solicitud de amistad enviada exitosamente"
                showAlert = true
            } catch {
                alertMessage = "Error: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}

struct FriendRequestRow: View {
    let request: FriendRequest
    let viewModel: FriendsViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(request.fromUserName)
                    .font(.headline)
                Text(request.fromUserEmail)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack {
                Button(action: { handleRequest(accept: true) }) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                
                Button(action: { handleRequest(accept: false) }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func handleRequest(accept: Bool) {
        Task {
            do {
                try await viewModel.handleFriendRequest(request, accept: accept)
            } catch {
                print("Error handling friend request: \(error)")
            }
        }
    }
} 
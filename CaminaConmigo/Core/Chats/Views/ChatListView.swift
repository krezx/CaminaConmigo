//
//  ChatListView.swift
//  CaminaConmigo
//
//  Created by a on 22-01-25.
//


import SwiftUI

struct ChatListView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header personalizado
                VStack {
                    Text("Chats")
                        .font(.title)
                        .bold()
                        .padding(.vertical, 5)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
                
                // Lista de chats
                ScrollView {
                    VStack(spacing: 0) {
                        ChatHeaderButtons()
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 0) {
                            ForEach(sampleChats) { chat in
                                ChatRowView(chat: chat)
                                    .padding(.horizontal)
                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct ChatHeaderButtons: View {
    var body: some View {
        HStack(spacing: 15) {
            Button(action: {}) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Añadir Amigo")
                }
            }
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "person.3")
                    Text("Crear Grupo")
                }
            }
        }
        .padding(.vertical, 15)
    }
}

struct ChatRowView: View {
    let chat: Chat
    
    var body: some View {
        NavigationLink(destination: ChatDetailView(chat: chat)) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(chat.name)
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        Text(chat.timeString)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Text(chat.lastMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct Chat: Identifiable {
    let id = UUID()
    let name: String
    let lastMessage: String
    let timeString: String
}

// Datos de ejemplo
let sampleChats = [
    Chat(name: "John Doe", lastMessage: "Tu: Ya llegué a mi destino amiga", timeString: "10 min"),
    Chat(name: "Jane Doe", lastMessage: "Avísame si saldrás hoy", timeString: "10 min"),
    Chat(name: "Familia", lastMessage: "Papá: Ya llegaron??", timeString: "33 min"),
    Chat(name: "Name", lastMessage: "Supporting line text lorem ipsum dolor...", timeString: "10 min"),
]

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView()
    }
}

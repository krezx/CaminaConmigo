//
//  ChatDetailView.swift
//  CaminaConmigo
//
//  Created by a on 24-01-25.
//


import SwiftUI

struct ChatDetailView: View {
    let chat: Chat
    @State private var messageText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ChatHeader(chat: chat)
            
            // Mensajes
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(sampleMessages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // Campo de entrada de mensaje
            MessageInputField(messageText: $messageText)
        }
        .navigationBarHidden(true)
    }
}

struct ChatHeader: View {
    let chat: Chat
    @Environment(\.presentationMode) var presentationMode
    
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
            Spacer()
            Text(chat.name)
                .font(.title)
                .bold()
                .padding(.vertical, 5)
            Spacer()
            VStack {
                ZStack {
                    // Ícono de ubicación
                    Image(systemName: "location")
                        .font(.caption)
                    // Onda izquierda
                    Image(systemName: "wave.3.left")
                        .font(.caption) // Más pequeño
                        .offset(x: -12, y: 0)
                    // Onda derecha
                    Image(systemName: "wave.3.right")
                        .font(.caption) // Más pequeño
                        .offset(x: 12, y: 0)
                }
            }
            .padding()
        }
        .background(Color.white)
        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer()
            }
            
            Text(message.content)
                .padding(12)
                .background(message.isFromCurrentUser ? Color.blue : Color(UIColor.systemGray5))
                .foregroundColor(message.isFromCurrentUser ? .white : .black)
                .cornerRadius(16)
            
            if !message.isFromCurrentUser {
                Spacer()
            }
        }
    }
}

struct MessageInputField: View {
    @Binding var messageText: String
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Escribe un mensaje...", text: $messageText)
                .padding(12)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
            
            Button(action: {
                // Enviar mensaje
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
    }
}

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isFromCurrentUser: Bool
}

// Datos de ejemplo
let sampleMessages = [
    Message(content: "¡Hola! ¿Qué vamos a hacer?", isFromCurrentUser: false),
    Message(content: "¿Pasta?", isFromCurrentUser: false),
    Message(content: "¡Suena bien!", isFromCurrentUser: true),
    Message(content: "¡Hagámoslo!", isFromCurrentUser: false)
] 

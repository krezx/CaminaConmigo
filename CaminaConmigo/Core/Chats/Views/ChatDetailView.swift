//
//  ChatDetailView.swift
//  CaminaConmigo
//
//  Created by a on 24-01-25.
//

import SwiftUI // Importa el framework SwiftUI para la construcción de la interfaz de usuario.

/// Vista que muestra los detalles de un chat, incluyendo el encabezado del chat, los mensajes y el campo de entrada de mensajes.
struct ChatDetailView: View {
    let chat: Chat // El chat que se va a mostrar.
    @State private var messageText: String = "" // El texto del mensaje que se está escribiendo en el campo de entrada.

    var body: some View {
        VStack(spacing: 0) {
            // Header del chat
            ChatHeader(chat: chat)
            
            // Vista de los mensajes
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(sampleMessages) { message in
                        MessageBubble(message: message) // Muestra cada mensaje en una burbuja.
                    }
                }
                .padding()
            }
            
            // Campo de entrada de mensaje
            MessageInputField(messageText: $messageText)
        }
        .navigationBarHidden(true) // Oculta la barra de navegación.
    }
}

/// Vista que representa el encabezado del chat, que incluye el nombre del chat y un botón para volver atrás.
struct ChatHeader: View {
    let chat: Chat // El chat para el cual se muestra el encabezado.
    @Environment(\.presentationMode) var presentationMode // Entorno para controlar la navegación y regresar a la vista anterior.

    var body: some View {
        HStack(spacing: 12) {
            // Botón para volver a la vista anterior
            Button(action: {
                presentationMode.wrappedValue.dismiss() // Desvanece la vista de detalle del chat y regresa a la vista anterior.
            }) {
                Image(systemName: "arrow.left") // Icono de flecha hacia la izquierda
                    .foregroundColor(Color.black)
            }
            
            // Imagen de perfil del chat (simulada aquí con un círculo gris)
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
            
            Spacer()
            
            // Nombre del chat
            Text(chat.name)
                .font(.title)
                .bold()
                .padding(.vertical, 5)
            
            Spacer()
            
            // Íconos de ubicación y ondas de interacción
            VStack {
                ZStack {
                    // Icono de ubicación
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
        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2) // Sombra para dar profundidad al encabezado.
    }
}

/// Vista que representa una burbuja de mensaje, que muestra el contenido del mensaje y su estilo según el emisor.
struct MessageBubble: View {
    let message: Message // El mensaje que se va a mostrar.

    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer() // Añade espacio si el mensaje es del usuario actual.
            }

            // Muestra el contenido del mensaje dentro de una burbuja
            Text(message.content)
                .padding(12)
                .background(message.isFromCurrentUser ? Color.blue : Color(UIColor.systemGray5)) // El color de la burbuja depende de si el mensaje es del usuario actual.
                .foregroundColor(message.isFromCurrentUser ? .white : .black) // El color del texto depende de si es del usuario actual.
                .cornerRadius(16)
            
            if !message.isFromCurrentUser {
                Spacer() // Añade espacio si el mensaje no es del usuario actual.
            }
        }
    }
}

/// Vista que representa el campo de entrada donde el usuario puede escribir un mensaje.
struct MessageInputField: View {
    @Binding var messageText: String // El texto del mensaje que se está escribiendo (vinculado a la vista de ChatDetailView).

    var body: some View {
        HStack(spacing: 12) {
            // Campo de texto donde el usuario escribe el mensaje
            TextField("Escribe un mensaje...", text: $messageText)
                .padding(12)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
            
            // Botón para enviar el mensaje (actualmente no tiene funcionalidad implementada)
            Button(action: {
                // Enviar mensaje
            }) {
                Image(systemName: "arrow.up.circle.fill") // Icono de flecha hacia arriba
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
    }
}

/// Estructura que representa un mensaje individual.
struct Message: Identifiable {
    let id = UUID() // ID único para el mensaje.
    let content: String // Contenido del mensaje.
    let isFromCurrentUser: Bool // Indica si el mensaje es del usuario actual o de otro participante.
}

// Datos de ejemplo para mostrar en el chat.
let sampleMessages = [
    Message(content: "¡Hola! ¿Qué vamos a hacer?", isFromCurrentUser: false),
    Message(content: "¿Pasta?", isFromCurrentUser: false),
    Message(content: "¡Suena bien!", isFromCurrentUser: true),
    Message(content: "¡Hagámoslo!", isFromCurrentUser: false)
]

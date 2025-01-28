//
//  NovedadView.swift
//  CaminaConmigo
//
//  Created by a on 20-01-25.
//

import SwiftUI // Importa el framework SwiftUI para crear la interfaz de usuario

/// Vista principal para mostrar novedades y reportes.
struct NovedadView: View {
    @State private var searchText = "" // Texto de búsqueda
    @State private var selectedFilter = "Tendencias" // Filtro seleccionado
    let filters = ["Tendencias", "Recientes", "Ciudad"] // Filtros disponibles para las novedades
    
    var body: some View {
        VStack(spacing: 0) {
            // Barra superior con búsqueda y filtros
            HStack(spacing: 12) {
                // Botón de búsqueda
                Button(action: {}) {
                    Image(systemName: "magnifyingglass") // Icono de búsqueda
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 40)
                }
                
                // Filtros horizontales para cambiar la categoría de las novedades
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(filters, id: \.self) { filter in
                            FilterButton(title: filter,
                                       isSelected: filter == selectedFilter) {
                                selectedFilter = filter
                            }
                        }
                    }
                }
            }
            .padding(.horizontal) // Añade espacio horizontal para la barra de búsqueda y filtros
            
            // Lista de reportes
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(0..<5) { _ in
                        ReporteCard() // Muestra un reporte en forma de tarjeta
                    }
                }
                .padding() // Añade espacio alrededor de la lista de reportes
            }
        }
    }
}

/// Barra de búsqueda que permite al usuario ingresar texto para buscar novedades.
struct SearchBar: View {
    @Binding var text: String // Enlace de datos para el texto de búsqueda
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass") // Icono de búsqueda
                .foregroundColor(.gray)
            TextField("Buscar", text: $text) // Campo de texto para búsqueda
        }
        .padding(8)
        .background(Color(.systemGray6)) // Fondo gris para la barra de búsqueda
        .cornerRadius(10) // Bordes redondeados
        .padding(.horizontal) // Espacio horizontal adicional
    }
}

/// Botón de filtro que permite seleccionar entre diferentes filtros para las novedades.
struct FilterButton: View {
    let title: String // Título del filtro
    let isSelected: Bool // Determina si el filtro está seleccionado
    let action: () -> Void // Acción que se ejecuta al seleccionar el filtro
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color(red: 239/255, green: 96/255, blue: 152/255) : Color(.systemGray6)) // Color de fondo dependiendo de si el filtro está seleccionado
                .foregroundColor(isSelected ? .white : .black) // Color del texto dependiendo de si el filtro está seleccionado
                .cornerRadius(20) // Bordes redondeados
        }
    }
}

/// Vista que representa una tarjeta de reporte. Cada tarjeta contiene información sobre un reporte, incluyendo un mapa, una descripción y botones de interacción.
struct ReporteCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header del reporte con usuario y tiempo de publicación
            HStack {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray) // Imagen de perfil del usuario (simulada con un círculo gris)
                VStack(alignment: .leading) {
                    Text("Usuario")
                        .fontWeight(.bold) // Nombre de usuario en negrita
                    Text("Hace 1h") // Tiempo desde la publicación
                        .foregroundColor(.gray)
                }
            }
            
            // Mapa representado como un rectángulo con texto
            Rectangle()
                .frame(height: 200)
                .foregroundColor(Color(.systemGray5))
                .overlay(
                    Text("Mapa")
                        .foregroundColor(.gray) // Texto que indica que es un mapa
                )
            
            // Descripción del reporte
            Text("Persona en situación de calle")
                .fontWeight(.medium)
            
            // Botones de interacción para dar "me gusta", comentar y compartir
            HStack {
                Button(action: {}) {
                    Image(systemName: "heart") // Ícono de corazón
                        .bold()
                    Text("10") // Número de "me gusta"
                }
                Button(action: {}) {
                    Image(systemName: "bubble.right") // Ícono de comentario
                        .bold()
                    Text("5") // Número de comentarios
                }
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up") // Ícono de compartir
                        .bold()
                    Text("Compartir") // Texto de compartir
                }
            }
            .foregroundColor(.black) // Color del texto y los íconos
        }
        .padding() // Añade espacio alrededor de la tarjeta
        .background(Color.white) // Fondo blanco para la tarjeta
        .cornerRadius(12) // Bordes redondeados
        .shadow(radius: 2) // Sombra para dar un efecto de elevación
    }
}

#Preview {
    NovedadView() // Vista previa de NovedadView
}

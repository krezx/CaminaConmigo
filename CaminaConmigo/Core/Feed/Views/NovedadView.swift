//
//  NovedadView.swift
//  CaminaConmigo
//
//  Created by a on 20-01-25.
//

import SwiftUI

struct NovedadView: View {
    @State private var searchText = ""
    @State private var selectedFilter = "Tendencias"
    let filters = ["Tendencias", "Recientes", "Ciudad"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Barra superior con búsqueda y filtros
            HStack(spacing: 12) {
                // Botón de búsqueda
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 40)
                }
                
                // Filtros scrolleables
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
            .padding(.horizontal)
            
            // Lista de reportes
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(0..<5) { _ in
                        ReporteCard()
                    }
                }
                .padding()
            }
        }
    }
}

// Componentes auxiliares
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Buscar", text: $text)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color(red: 239/255, green: 96/255, blue: 152/255) : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(20)
        }
    }
}

struct ReporteCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header del reporte
            HStack {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                VStack(alignment: .leading) {
                    Text("Usuario")
                        .fontWeight(.bold)
                    Text("Hace 1h")
                        .foregroundColor(.gray)
                }
            }
            
            // Mapa
            Rectangle()
                .frame(height: 200)
                .foregroundColor(Color(.systemGray5))
                .overlay(
                    Text("Mapa")
                        .foregroundColor(.gray)
                )
            
            // Descripción
            Text("Persona en situación de calle")
                .fontWeight(.medium)
            
            // Botones de interacción
            HStack {
                Button(action: {}) {
                    Image(systemName: "heart")
                        .bold()
                    Text("10")
                }
                Button(action: {}) {
                    Image(systemName: "bubble.right")
                        .bold()
                    Text("5")
                }
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .bold()
                    Text("Compartir")
                }
            }
            .foregroundColor(.black)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    NovedadView()
}

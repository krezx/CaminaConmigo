//
//  NovedadView.swift
//  CaminaConmigo
//
//  Created by a on 20-01-25.
//

import SwiftUI // Importa el framework SwiftUI para crear la interfaz de usuario
import MapKit

/// Vista principal para mostrar novedades y reportes.
struct NovedadView: View {
    @StateObject private var viewModel = ReportViewModel()
    @State private var searchText = "" // Texto de búsqueda
    @State private var selectedFilter = "Tendencias" // Filtro seleccionado
    @State private var selectedReport: ReportAnnotation?
    @State private var showReportDetail = false
    private let filters = ["Tendencias", "Recientes", "Ciudad"] // Filtros disponibles para las novedades
    
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
                            FilterButton(
                                title: filter,
                                isSelected: filter == selectedFilter,
                                action: {
                                    selectedFilter = filter
                                    viewModel.filterReports(by: filter)
                                }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal) // Añade espacio horizontal para la barra de búsqueda y filtros
            
            // Lista de reportes
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.filteredReports) { report in
                        ReporteCard(report: report, viewModel: viewModel)
                            .onTapGesture {
                                selectedReport = report
                                showReportDetail = true
                            }
                    }
                }
                .padding() // Añade espacio alrededor de la lista de reportes
            }
        }
        .sheet(isPresented: $showReportDetail) {
            if let report = selectedReport {
                ReportDetailPopupView(report: report, viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.fetchReports()
            viewModel.filterReports(by: selectedFilter)
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
    let report: ReportAnnotation
    @State private var region: MKCoordinateRegion
    @State private var commentCount: Int = 0
    @ObservedObject var viewModel: ReportViewModel
    
    init(report: ReportAnnotation, viewModel: ReportViewModel) {
        self.report = report
        self.viewModel = viewModel
        _region = State(initialValue: MKCoordinateRegion(
            center: report.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header con icono y tipo de reporte
            HStack {
                Image(report.report.type.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading) {
                    Text(report.report.type.title)
                        .font(.headline)
                    Text("hace " + timeAgoDisplay(date: report.report.timestamp))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Descripción del reporte
            Text(report.report.description)
                .lineLimit(3)
                .padding(.vertical, 4)
            
            // Mapa
            Map(coordinateRegion: .constant(region),
                annotationItems: [report]) { location in
                MapMarker(coordinate: location.coordinate)
            }
            .frame(height: 200)
            .cornerRadius(12)
            .allowsHitTesting(false)
            
            // Botones de interacción
            HStack(spacing: 20) {
                Button(action: {}) {
                    Image(systemName: "heart")
                        .bold()
                    Text("\(report.report.likes) Me gusta")
                }
                Button(action: {}) {
                    Image(systemName: "bubble.right")
                        .bold()
                    Text("\(commentCount) Comentarios")
                }
            }
            .foregroundColor(.black)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .onAppear {
            if let reportId = report.report.id {
                viewModel.getCommentCount(for: reportId) { count in
                    commentCount = count
                }
            }
        }
    }
    
    private func timeAgoDisplay(date: Date) -> String {
        let seconds = -date.timeIntervalSinceNow
        
        let minute = 60.0
        let hour = minute * 60
        let day = hour * 24
        let week = day * 7
        let month = day * 30
        let year = day * 365
        
        switch seconds {
        case 0..<minute:
            return "hace un momento"
        case minute..<hour:
            let minutes = Int(seconds/minute)
            return "hace \(minutes) \(minutes == 1 ? "minuto" : "minutos")"
        case hour..<day:
            let hours = Int(seconds/hour)
            return "hace \(hours) \(hours == 1 ? "hora" : "horas")"
        case day..<week:
            let days = Int(seconds/day)
            return "hace \(days) \(days == 1 ? "día" : "días")"
        case week..<month:
            let weeks = Int(seconds/week)
            return "hace \(weeks) \(weeks == 1 ? "semana" : "semanas")"
        case month..<year:
            let months = Int(seconds/month)
            return "hace \(months) \(months == 1 ? "mes" : "meses")"
        default:
            let years = Int(seconds/year)
            return "hace \(years) \(years == 1 ? "año" : "años")"
        }
    }
}

#Preview {
    NovedadView() // Vista previa de NovedadView
}

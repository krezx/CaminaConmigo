//
//  NovedadView.swift
//  CaminaConmigo
//
//  Created by a on 20-01-25.
//

import SwiftUI // Importa el framework SwiftUI para crear la interfaz de usuario
import MapKit
import SwiftUI

/// Vista principal para mostrar novedades y reportes.
struct NovedadView: View {
    @StateObject private var viewModel = ReportViewModel()
    @State private var searchText = ""
    @State private var showSearchBar = false
    @State private var selectedFilter = "Tendencias"
    @State private var selectedReport: ReportAnnotation?
    @State private var showReportDetail = false
    @State private var isLoading = false
    private let filters = ["Tendencias", "Recientes", "Ciudad"] // Filtros disponibles para las novedades
    
    var body: some View {
        VStack(spacing: 0) {
            // Barra superior con búsqueda y filtros
            VStack {
                HStack(spacing: 12) {
                    if showSearchBar {
                        // Barra de búsqueda expandida
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Buscar reportes...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .onChange(of: searchText) { newValue in
                                    viewModel.searchReports(query: newValue)
                                }
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                    viewModel.searchReports(query: "")
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            Button("Cancelar") {
                                withAnimation {
                                    showSearchBar = false
                                    searchText = ""
                                    viewModel.searchReports(query: "")
                                }
                            }
                            .foregroundColor(.gray)
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    } else {
                        // Botón de búsqueda y filtros
                        Button(action: {
                            withAnimation {
                                showSearchBar = true
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .frame(width: 40, height: 40)
                        }
                        
                        // Filtros horizontales
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(filters, id: \.self) { filter in
                                    FilterButton(
                                        title: filter,
                                        isSelected: filter == selectedFilter,
                                        action: {
                                            withAnimation {
                                                selectedFilter = filter
                                                viewModel.filterReports(by: filter)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Lista de reportes
            ScrollView {
                if !searchText.isEmpty {
                    // Mostrar resultados de búsqueda
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.searchResults) { report in
                            ReporteCard(report: report, viewModel: viewModel)
                                .onTapGesture {
                                    handleReportSelection(report)
                                }
                        }
                    }
                    .padding()
                } else if selectedFilter == "Ciudad" && viewModel.isLoadingCity {
                    VStack {
                        Spacer()
                        ProgressView("Cargando reportes por ciudad...")
                            .padding()
                        Spacer()
                    }
                    .frame(height: 100)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredReports) { report in
                            ReporteCard(report: report, viewModel: viewModel)
                                .onTapGesture {
                                    handleReportSelection(report)
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showReportDetail) {
            if let report = selectedReport {
                ReportDetailPopupView(report: report, viewModel: viewModel)
            }
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .onAppear {
            viewModel.fetchReports()
            viewModel.filterReports(by: selectedFilter)
        }
    }
    private func handleReportSelection(_ report: ReportAnnotation) {
        isLoading = true
        
        if let reportId = report.report.id {
            print("Selected report userId: \(report.report.userId)") // Depuración
            viewModel.fetchSpecificReport(reportId) { updatedReport in
                if let updatedReport = updatedReport {
                    // Preservar el campo isAnonymous del reporte original
                    var modifiedReport = updatedReport
                    modifiedReport.isAnonymous = report.report.isAnonymous
                    selectedReport = ReportAnnotation(report: modifiedReport)
                    showReportDetail = true
                }
                isLoading = false
            }
        } else {
            isLoading = false
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
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? 
                            Color(red: 239/255, green: 96/255, blue: 152/255) : 
                            Color(.systemGray6)
                        )
                )
                .foregroundColor(isSelected ? .white : .black)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? 
                            Color(red: 239/255, green: 96/255, blue: 152/255) : 
                            Color.clear, 
                            lineWidth: 1
                        )
                )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

/// Vista que representa una tarjeta de reporte. Cada tarjeta contiene información sobre un reporte, incluyendo un mapa, una descripción y botones de interacción.
struct ReporteCard: View {
    let report: ReportAnnotation
    @State private var region: MKCoordinateRegion
    @State private var commentCount: Int = 0
    @State private var authorUsername: String?
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
            // Header con icono, tipo de reporte y autor
            HStack {
                Image(report.report.type.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading) {
                    Text(report.report.type.title)
                        .font(.headline)
                        .foregroundColor(Color.customText)
                    
                    HStack {
                        if !report.report.isAnonymous, let username = authorUsername {
                            Text("por \(username)")
                                .font(.subheadline)
                                .foregroundColor(Color.customText.opacity(0.8))
                        }
                        Text("hace " + timeAgoDisplay(date: report.report.timestamp))
                            .font(.caption)
                            .foregroundColor(Color.customText.opacity(0.8))
                    }
                }
            }
            
            // Descripción del reporte
            Text(report.report.description)
                .lineLimit(3)
                .padding(.vertical, 4)
                .foregroundColor(Color.customText)
            
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
                        .foregroundColor(Color.customText)
                    Text("\(report.report.likes) Me gusta")
                        .foregroundColor(Color.customText)
                }
                Button(action: {}) {
                    Image(systemName: "bubble.right")
                        .bold()
                        .foregroundColor(Color.customText)
                    Text("\(commentCount) Comentarios")
                        .foregroundColor(Color.customText)
                }
            }
            .foregroundColor(Color.customText)
        }
        .padding()
        .background(Color.customSecondaryBackground)
        .cornerRadius(12)
        .shadow(radius: 2)
        .onAppear {
            if let reportId = report.report.id {
                viewModel.getCommentCount(for: reportId) { count in
                    commentCount = count
                }
                
                // Obtener el nombre del autor si el reporte no es anónimo
                if !report.report.isAnonymous {
                    viewModel.fetchAuthorUsername(userId: report.report.userId) { username in
                        authorUsername = username
                    }
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

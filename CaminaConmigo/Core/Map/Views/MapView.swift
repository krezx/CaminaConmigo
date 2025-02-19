//
//  MapView.swift
//  CaminaConmigo
//
//  Created by a on 28-01-25.
//


import SwiftUI
import MapKit

/// Vista principal del mapa donde el usuario puede interactuar con el mapa, buscar ubicaciones,
/// y enviar reportes a través de un formulario. Incluye botones de emergencia y acciones interactivas.
struct MapView: View {
    @StateObject private var viewModel = MapViewModel()  // El ViewModel que maneja la lógica de la vista del mapa.
    @StateObject private var reportViewModel = ReportViewModel()  // El ViewModel que maneja la lógica de la vista del mapa.
    @StateObject private var shakeDetector = ShakeDetector()  
    @State private var searchText = ""  // El texto de búsqueda para la ubicación.
    @StateObject private var locationManager = LocationManager()
    @State private var centerCoordinate: CLLocationCoordinate2D?
    @State private var selectedReport: ReportAnnotation?
    @State private var showEmergencyCall = false
    @State private var showReportDetail = false  // Nuevo estado para controlar la presentación
    @AppStorage("shakeEnabled") private var shakeEnabled = true  // Agregar esta línea
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    var body: some View {
        ZStack {
            // Vista del mapa representado en un contenedor que ocupa toda la pantalla.
            MapViewRepresentable(
                locationManager: locationManager,
                centerCoordinate: $centerCoordinate,
                viewModel: reportViewModel,
                selectedReport: $selectedReport,
                searchLocation: $viewModel.searchLocation
            )
            .ignoresSafeArea()  // Ignora las áreas seguras del dispositivo (por ejemplo, las muescas en pantallas).
            .onChange(of: selectedReport) { newValue in
                if newValue != nil {
                    showReportDetail = true
                }
            }
            .onTapGesture {
                hideKeyboard()
                viewModel.clearSearch()
            }
            .onChange(of: viewModel.isSearchActive) { isActive in
                if !isActive {
                    searchText = ""
                }
            }

            VStack {
                // Barra superior que contiene el logo y la barra de búsqueda
                HStack {
                    Image("logo1")  // Logo de la aplicación.
                        .resizable()
                        .scaledToFit()
                        .frame(height: 38)
                    
                    // Barra de búsqueda para permitir la búsqueda de ubicaciones.
                    HStack {
                        Image(systemName: "magnifyingglass")  // Icono de búsqueda.
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        
                        TextField("Buscar ubicación...", text: $searchText)  // Campo de texto para la búsqueda.
                            .onChange(of: searchText) { newValue in
                                viewModel.searchAddress(newValue)
                            }
                    }
                    .padding(8)
                    .background(.ultraThinMaterial.opacity(0.6))  // Fondo con material translúcido.
                    .cornerRadius(30)
                }
                .padding()
                
                // Resultados de búsqueda
                if !viewModel.searchResults.isEmpty && !searchText.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(viewModel.searchResults, id: \.self) { result in
                                Button(action: {
                                    viewModel.selectSearchResult(result)
                                    hideKeyboard()
                                }) {
                                    VStack(alignment: .leading) {
                                        Text(result.title)
                                            .foregroundColor(.primary)
                                        Text(result.subtitle)
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                }
                                .padding(.vertical, 4)
                                Divider()
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 200)
                }
                
                Spacer()  // Espaciado para separar la barra superior del resto de la interfaz.

                // Botones interactivos en la parte inferior derecha de la pantalla.
                VStack {
                    // Botones laterales derechos (SOS, compartir, ayuda)
                    HStack {
                        Spacer()  // Empuja los botones hacia la derecha.
                        VStack(spacing: 12) {
                            Spacer()  // Empuja los botones hacia abajo.
                            
                            // Botón SOS
                            Button(action: {
                                showEmergencyCall = true
                            }) {
                                Text("SOS")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.red)  // Fondo rojo para el botón SOS.
                                    .clipShape(Circle())  // Hace el botón redondeado.
                            }
                            .popover(isPresented: $showEmergencyCall, attachmentAnchor: .point(.top), arrowEdge: .bottom) {
                                EmergencyCallView()
                            }
                            
                            // Botón para compartir (debe implementar funcionalidad)
                            Button(action: {
                                // Acción del botón compartir.
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.purple)
                                    .frame(width: 44, height: 44)
                                    .background(.white)
                                    .clipShape(Circle())  // Botón circular.
                            }
                            
                            // Botón de ayuda (debe implementar funcionalidad)
                            Button(action: {
                                // Acción del botón ayuda.
                            }) {
                                Image(systemName: "questionmark")
                                    .foregroundColor(.purple)
                                    .frame(width: 44, height: 44)
                                    .background(.white)
                                    .clipShape(Circle())  // Botón circular.
                            }
                        }
                        .padding()
                    }
                }

                // Botón de "REPORTE" centrado en la parte inferior de la pantalla.
                VStack {
                    Button(action: {
                        // Muestra la hoja para crear un nuevo reporte.
                        reportViewModel.showReportSheet = true
                    }) {
                        Text("REPORTE")
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.white)
                            .cornerRadius(20)
                    }
                    .padding(.bottom)
                }
            }
        }
        // Hoja para seleccionar el tipo de reporte.
        .sheet(isPresented: $reportViewModel.showReportSheet) {
            ReportSheetView(viewModel: reportViewModel)  // Vista para crear un reporte.
        }
        // Hoja para completar los detalles del reporte seleccionado.
        .sheet(isPresented: $reportViewModel.showReportDetailSheet) {
            ReportDetailView(viewModel: reportViewModel)  // Vista para ingresar detalles del reporte.
        }
        .sheet(isPresented: $showReportDetail, onDismiss: {
            selectedReport = nil
        }) {
            if let report = selectedReport {
                ReportDetailPopupView(report: report, viewModel: reportViewModel)
            }
        }
        .onChange(of: shakeEnabled) { newValue in
            if newValue {
                shakeDetector.restartMonitoring()
            } else {
                shakeDetector.stopMonitoring()
            }
        }
        .onAppear {
            if shakeEnabled {
                shakeDetector.restartMonitoring()
            }
            shakeDetector.onShakeDetected = {
                if shakeEnabled {
                    showEmergencyCall = true
                }
            }
        }
        .onDisappear {
            shakeDetector.stopMonitoring()
        }
    }
}
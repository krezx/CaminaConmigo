//
//  MapView.swift
//  CaminaConmigo
//
//  Created by a on 22-01-25.
//

import SwiftUI

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            MapViewRepresentable()
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Image("logo1")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 38)
                    
                    // Barra de búsqueda
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        
                        TextField("Buscar ubicación...", text: $searchText)
                    }
                    .padding(8)
                    .background(.ultraThinMaterial.opacity(0.6))
                    .cornerRadius(30)
                }
                .padding()
                
                Spacer()
                
                // Botones inferiores en capas separadas
                VStack {
                    // Botones laterales derechos
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            Spacer()
                            Button(action: {
                                // Acción del botón SOS
                            }) {
                                Text("SOS")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.red)
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                // Acción del botón compartir
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.purple)
                                    .frame(width: 44, height: 44)
                                    .background(.white)
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                // Acción del botón ayuda
                            }) {
                                Image(systemName: "questionmark")
                                    .foregroundColor(.purple)
                                    .frame(width: 44, height: 44)
                                    .background(.white)
                                    .clipShape(Circle())
                            }
                        }
                        .padding()
                        
                    }
                }
                // Botón REPORTE centrado en la parte inferior
                VStack {
                    Button(action: {
                        viewModel.showReportSheet = true
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
        .sheet(isPresented: $viewModel.showReportSheet) {
            ReportSheetView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showReportDetailSheet) {
            ReportDetailView(viewModel: viewModel)
        }
    }
}

#Preview {
    MapView()
}

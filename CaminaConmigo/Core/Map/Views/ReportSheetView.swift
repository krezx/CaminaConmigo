//
//  ReportSheetView.swift
//  CaminaConmigo
//
//  Created by a on 23-01-25.
//


import SwiftUI

struct ReportSheetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: MapViewModel
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            Text("REPORTE")
                .font(.headline)
                .padding(.top)
            
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.reportTypes) { type in
                    Button {
                        viewModel.handleReport(type: type)
                        dismiss()
                    } label: {
                        VStack {
                            Image(type.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.purple)
                            
                            Text(type.title)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                        }
                        .frame(height: 80)
                    }
                }
            }
            .padding()
            
            Button("Cerrar") {
                dismiss()
            }
            .foregroundColor(.purple)
            .padding(.bottom)
        }
        .background(Color.white)
        .cornerRadius(20)
        .padding()
    }
} 

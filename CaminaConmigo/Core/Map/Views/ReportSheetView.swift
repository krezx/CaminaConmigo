//
//  ReportSheetView.swift
//  CaminaConmigo
//
//  Created by a on 23-01-25.
//

import SwiftUI

/// Vista que muestra un listado de tipos de reporte disponibles para que el usuario elija uno.
/// Al seleccionar un tipo de reporte, se maneja la lógica del reporte y se cierra la vista actual.
struct ReportSheetView: View {
    @Environment(\.dismiss) var dismiss  // Permite cerrar la vista de selección de reporte.
    @ObservedObject var viewModel: ReportViewModel  // El ViewModel que maneja los tipos de reportes y la lógica asociada.
    
    // Definición de columnas para el Grid (dos columnas flexibles).
    let columns = [
        GridItem(.flexible()),  // Primera columna flexible.
        GridItem(.flexible())   // Segunda columna flexible
    ]
    
    var body: some View {
        VStack {
            // Título de la vista de reportes.
            Text("REPORTE")
                .font(.headline)
                .padding(.top)  // Espaciado superior para separar del borde.
            
            // Vista de rejilla (LazyVGrid) para mostrar los tipos de reporte.
            LazyVGrid(columns: columns, spacing: 20) {
                // Itera sobre los tipos de reporte y genera un botón para cada uno.
                ForEach(viewModel.reportTypes) { type in
                    Button {
                        viewModel.handleReport(type: type)  // Maneja el tipo de reporte seleccionado.
                        dismiss()  // Cierra la vista después de seleccionar un reporte.
                    } label: {
                        VStack {
                            Image(type.imageName)  // Muestra el ícono asociado al tipo de reporte.
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.purple)  // Color del ícono.
                            
                            Text(type.title)  // Título del tipo de reporte.
                                .font(.caption)
                                .multilineTextAlignment(.center)  // Centra el texto.
                                .foregroundColor(.black)  // Color del texto.
                        }
                        .frame(height: 80)  // Define la altura del botón.
                    }
                }
            }
            .padding()  // Espaciado dentro del LazyVGrid.
            
            // Botón de cierre para salir de la vista de selección de reporte.
            Button("Cerrar") {
                dismiss()  // Cierra la vista cuando se presiona.
            }
            .foregroundColor(.purple)  // Color del texto del botón de cierre.
            .padding(.bottom)  // Espaciado inferior.
        }
        .background(Color.white)  // Fondo blanco para toda la vista.
        .cornerRadius(20)  // Bordes redondeados para la vista.
        .padding()  // Espaciado exterior para alejar de los bordes de la pantalla.
    }
}

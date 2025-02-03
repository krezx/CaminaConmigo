//
//  MapPickerView.swift
//  CaminaConmigo
//
//  Created by a on 29-01-25.
//


import SwiftUI
import MapKit

struct MapPickerView: View {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ReportViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var centerCoordinate: CLLocationCoordinate2D?

    var body: some View {
        ZStack {
            MapViewRepresentable(
                locationManager: locationManager, 
                centerCoordinate: $centerCoordinate,
                viewModel: viewModel,
                selectedReport: .constant(nil)
            )
            VStack {
               Spacer()  // Empuja el mappin hacia el centro
               Image(systemName: "mappin")
                   .font(.system(size: 50))  // Puedes ajustar el tamaño del mappin
                   .foregroundColor(.red)   // Cambia el color si lo deseas
               Spacer()  // Mantiene el mappin centrado verticalmente
               Button("Seleccionar esta ubicación") {
                   if let coordinate = centerCoordinate {
                       viewModel.selectedLocation = coordinate
                       // Actualizamos directamente las coordenadas del reporte
                       viewModel.currentReport?.coordinate = coordinate
                   }
                   dismiss()
               }
               .padding()
               .background(Color.blue)
               .foregroundColor(.white)
               .cornerRadius(8)
               .padding(.bottom)  // Agrega un espacio desde el borde inferior
           }
           .frame(maxHeight: .infinity)  // Asegura que la VStack ocupe todo el espacio vertical
        }
    }
}

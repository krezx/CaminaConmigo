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
    @Binding var selectedAddress: String
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ReportViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var centerCoordinate: CLLocationCoordinate2D?
    @State private var isGettingAddress = false
    
    func getAddressFromCoordinate(_ coordinate: CLLocationCoordinate2D) {
        isGettingAddress = true
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Error en geocodificación: \(error.localizedDescription)")
                selectedAddress = "Ubicación seleccionada"
                isGettingAddress = false
                return
            }
            
            if let placemark = placemarks?.first {
                let thoroughfare = placemark.thoroughfare ?? ""
                let subThoroughfare = placemark.subThoroughfare ?? ""
                let locality = placemark.locality ?? ""
                
                selectedAddress = "\(thoroughfare) \(subThoroughfare), \(locality)".trimmingCharacters(in: .whitespaces)
                if selectedAddress.isEmpty {
                    selectedAddress = "Ubicación seleccionada"
                }
            } else {
                selectedAddress = "Ubicación seleccionada"
            }
            isGettingAddress = false
        }
    }

    var body: some View {
        ZStack {
            MapViewRepresentable(
                locationManager: locationManager,
                centerCoordinate: $centerCoordinate,
                viewModel: viewModel,
                selectedReport: .constant(nil)
            )
            VStack {
                Spacer()
                Image(systemName: "mappin")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                Spacer()
                Button {
                    if let coordinate = centerCoordinate {
                        viewModel.selectedLocation = coordinate
                        viewModel.currentReport?.coordinate = coordinate
                        getAddressFromCoordinate(coordinate)
                        dismiss()
                    }
                } label: {
                    HStack {
                        if isGettingAddress {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("Seleccionar esta ubicación")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.bottom)
            }
            .frame(maxHeight: .infinity)
        }
    }
}

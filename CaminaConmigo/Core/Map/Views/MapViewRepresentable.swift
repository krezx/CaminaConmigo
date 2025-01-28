//
//  MapViewRepresentable.swift
//  CaminaConmigo
//
//  Created by a on 28-01-25.
//

import SwiftUI
import MapKit

/// Representación de una vista de mapa (MKMapView) en SwiftUI, permitiendo la integración de
/// funcionalidades de mapas nativos con la interfaz de usuario de SwiftUI.
/// La vista permite mostrar la ubicación del usuario y actualizar la región del mapa.
struct MapViewRepresentable: UIViewRepresentable {
    
    let mapView = MKMapView()  // Instancia del mapa que se mostrará en la vista.
    let locationManager = LocationManager()  // Instancia del manejador de ubicación, aunque no se usa directamente aquí.
    
    /// Crea la vista del mapa para ser utilizada en SwiftUI.
    ///
    /// - Parameter context: El contexto que permite la comunicación con SwiftUI.
    /// - Returns: La vista del mapa representada por un MKMapView.
    func makeUIView(context: Context) -> some UIView {
        mapView.delegate = context.coordinator  // Asigna el coordinador como delegado del mapa.
        mapView.isRotateEnabled = false  // Deshabilita la rotación del mapa.
        mapView.showsUserLocation = true  // Muestra la ubicación actual del usuario en el mapa.
        mapView.userTrackingMode = .none  // No realiza un seguimiento activo del movimiento del usuario.
        
        return mapView  // Devuelve la vista del mapa para mostrarla en la interfaz.
    }
    
    /// Actualiza la vista del mapa si es necesario (en este caso, no hay ninguna actualización definida).
    ///
    /// - Parameter uiView: La vista del mapa que necesita ser actualizada.
    /// - Parameter context: El contexto que permite la comunicación con SwiftUI.
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // Aquí puedes manejar cualquier actualización de la vista si es necesario
    }
    
    /// Crea el coordinador que maneja los eventos del mapa, como la actualización de la ubicación del usuario.
    ///
    /// - Returns: Un coordinador que se encarga de gestionar los eventos del mapa.
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self)  // Inicializa el coordinador con la vista principal.
    }
}

extension MapViewRepresentable {
    
    /// Coordinador encargado de gestionar los eventos del mapa, como la actualización de la ubicación.
    class MapCoordinator: NSObject, MKMapViewDelegate {
        let parent: MapViewRepresentable  // Referencia a la vista principal.
        var initialLocationSet = false  // Controla si la ubicación inicial ya se ha configurado.
        
        init(parent: MapViewRepresentable) {
            self.parent = parent
            super.init()
        }
        
        /// Método delegado que se llama cuando la ubicación del usuario se actualiza.
        ///
        /// - Parameter mapView: El mapa que ha recibido la actualización.
        /// - Parameter userLocation: La nueva ubicación del usuario.
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            guard !initialLocationSet else { return }  // Verifica que la ubicación inicial no haya sido ya configurada.
            
            // Configura la región del mapa con la ubicación del usuario.
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: userLocation.coordinate.latitude,
                    longitude: userLocation.coordinate.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)  // Define el rango de zoom del mapa.
            )
            
            parent.mapView.setRegion(region, animated: true)  // Actualiza la región del mapa con animación.
            initialLocationSet = true  // Marca que la ubicación inicial ha sido configurada.
        }
    }
}

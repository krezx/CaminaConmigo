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
    let locationManager: LocationManager
    @Binding var centerCoordinate: CLLocationCoordinate2D?
    @ObservedObject var viewModel: ReportViewModel
    @Binding var selectedReport: ReportAnnotation?
    @Binding var searchLocation: CLLocationCoordinate2D?
    
    /// Crea la vista del mapa para ser utilizada en SwiftUI.
    ///
    /// - Parameter context: El contexto que permite la comunicación con SwiftUI.
    /// - Returns: La vista del mapa representada por un MKMapView.
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator  // Asigna el coordinador como delegado del mapa.
        mapView.isRotateEnabled = false  // Deshabilita la rotación del mapa.
        mapView.showsUserLocation = true  // Muestra la ubicación actual del usuario en el mapa.
        mapView.userTrackingMode = .none  // No realiza un seguimiento activo del movimiento del usuario.
        
        // Gestor de gestos para detectar cuando el usuario mueve el mapa
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(MapCoordinator.handleMapPan(_:)))
        
        // Agregar gesto de toque
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(MapCoordinator.handleMapTap(_:)))
        
        mapView.addGestureRecognizer(panGesture)
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView  // Devuelve la vista del mapa para mostrarla en la interfaz.
    }
    
    /// Actualiza la vista del mapa si es necesario (en este caso, no hay ninguna actualización definida).
    ///
    /// - Parameter uiView: La vista del mapa que necesita ser actualizada.
    /// - Parameter context: El contexto que permite la comunicación con SwiftUI.
    func updateUIView(_ uiView: MKMapView, context: Context) {
        updateAnnotations(in: uiView)
        
        // Actualizar el pin de búsqueda
        if let searchLocation = searchLocation {
            let annotation = MKPointAnnotation()
            annotation.coordinate = searchLocation
            
            // Remover pins de búsqueda anteriores
            uiView.removeAnnotations(uiView.annotations.filter { $0 is MKPointAnnotation })
            
            uiView.addAnnotation(annotation)
            
            // Centrar el mapa en la ubicación buscada
            let region = MKCoordinateRegion(
                center: searchLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            uiView.setRegion(region, animated: true)
        }
    }
    
    private func updateAnnotations(in mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(viewModel.reports)
    }
    
    /// Crea el coordinador que maneja los eventos del mapa, como la actualización de la ubicación del usuario.
    ///
    /// - Returns: Un coordinador que se encarga de gestionar los eventos del mapa.
    func makeCoordinator() -> MapCoordinator {
        MapCoordinator(parent: self)  // Inicializa el coordinador con la vista principal.
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
            updateCenterCoordinate()
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
                    updateCenterCoordinate()
                }
                
                private func updateCenterCoordinate() {
                    parent.centerCoordinate = parent.mapView.centerCoordinate
                }
                
                @objc func handleMapPan(_ gesture: UIPanGestureRecognizer) {
                    if gesture.state == .ended {
                        updateCenterCoordinate()
                    }
                }
        
        @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
            // Limpiar la ubicación de búsqueda y remover el pin
            DispatchQueue.main.async {
                self.parent.searchLocation = nil
                self.parent.mapView.removeAnnotations(self.parent.mapView.annotations.filter { $0 is MKPointAnnotation })
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let reportAnnotation = annotation as? ReportAnnotation else { return nil }
            
            let identifier = "ReportAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            }
            
            // Configurar el tamaño de la imagen del marcador
            let size = CGSize(width: 40, height: 40)
            
            // Obtener la imagen correspondiente al tipo de reporte
            let imageName = reportAnnotation.report.type.markerImageName
            if let image = UIImage(named: imageName) {
                // Redimensionar la imagen al tamaño deseado
                UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                image.draw(in: CGRect(origin: .zero, size: size))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                // Asignar la imagen redimensionada al marcador
                annotationView?.image = resizedImage
            }
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let reportAnnotation = view.annotation as? ReportAnnotation {
                parent.selectedReport = reportAnnotation
            }
        }
    }
}

//
//  LocationManager.swift
//  CaminaConmigo
//
//  Created by a on 22-01-25.
//

import CoreLocation // Importa el framework CoreLocation para acceder a la ubicación del dispositivo.

/// Clase que gestiona el acceso y seguimiento de la ubicación del dispositivo.
class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager() // Instancia de CLLocationManager para obtener la ubicación del dispositivo.
    
    /// Inicializa el LocationManager configurando su delegado, precisión y solicitando autorización.
    override init() {
        super.init()
        locationManager.delegate = self // Establece el delegado de CLLocationManager como la propia clase.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Configura la precisión de la ubicación a la más alta posible.
        locationManager.requestWhenInUseAuthorization() // Solicita permiso para acceder a la ubicación mientras la app está en uso.
        locationManager.startUpdatingLocation() // Comienza la actualización de la ubicación.
    }
}

extension LocationManager: CLLocationManagerDelegate {
    /// Método delegado que se llama cuando se actualiza la ubicación del dispositivo.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Si la lista de ubicaciones está vacía, no hace nada.
        guard !locations.isEmpty else { return }
        
        // Detiene la actualización de la ubicación después de obtener la primera ubicación.
        locationManager.stopUpdatingLocation()
    }
}

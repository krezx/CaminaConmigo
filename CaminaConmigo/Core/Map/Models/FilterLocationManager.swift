import CoreLocation

class FilterLocationManager: NSObject, ObservableObject {
    static let shared = FilterLocationManager()
    private let manager = CLLocationManager()
    
    @Published var userLocation: CLLocationCoordinate2D?
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // No solicitamos autorización aquí ya que el LocationManager principal ya lo hace
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D? {
        return manager.location?.coordinate
    }
}

extension FilterLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLocation = location.coordinate
    }
} 
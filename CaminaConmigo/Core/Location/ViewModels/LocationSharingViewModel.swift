import Foundation
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class LocationSharingViewModel: NSObject, ObservableObject {
    @Published var activeLocationSharing: [String: LocationMessage] = [:]
    @Published var error: String?
    
    private let db = Firestore.firestore()
    private let locationManager = CLLocationManager()
    private var locationListeners: [String: ListenerRegistration] = [:]
    private var updateTimer: Timer?
    private var currentChatId: String?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Actualizar cada 10 metros
        
        // Verificar si tenemos los permisos necesarios
        if #available(iOS 14.0, *) {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                error = "Se requieren permisos de ubicación para compartir tu ubicación"
            default:
                break
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startSharingLocation(in chatId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        currentChatId = chatId
        
        // Verificar permisos antes de comenzar
        let authStatus = locationManager.authorizationStatus
        guard authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways else {
            error = "Se requieren permisos de ubicación para compartir tu ubicación"
            return
        }
        
        // Comenzar a actualizar la ubicación
        locationManager.startUpdatingLocation()
        
        // Crear documento inicial de ubicación
        if let location = locationManager.location {
            let locationMessage = LocationMessage(
                id: UUID().uuidString,
                senderId: currentUserId,
                timestamp: Date(),
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                isActive: true
            )
            
            // Guardar en Firestore
            db.collection("chats")
                .document(chatId)
                .collection("locationSharing")
                .document(currentUserId)
                .setData(locationMessage.dictionary)
        }
    }
    
    func stopSharingLocation(in chatId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        locationManager.stopUpdatingLocation()
        updateTimer?.invalidate()
        updateTimer = nil
        currentChatId = nil
        
        // Marcar como inactivo en Firestore
        db.collection("chats")
            .document(chatId)
            .collection("locationSharing")
            .document(currentUserId)
            .updateData(["isActive": false])
    }
    
    func listenToLocationUpdates(in chatId: String, for userId: String) {
        let listener = db.collection("chats")
            .document(chatId)
            .collection("locationSharing")
            .document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let document = snapshot else {
                    self?.error = error?.localizedDescription
                    return
                }
                
                if let data = document.data(),
                   let locationMessage = try? LocationMessage(
                    id: document.documentID,
                    senderId: data["senderId"] as? String ?? "",
                    timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                    latitude: data["latitude"] as? Double ?? 0,
                    longitude: data["longitude"] as? Double ?? 0,
                    isActive: data["isActive"] as? Bool ?? false
                   ) {
                    DispatchQueue.main.async {
                        self?.activeLocationSharing[userId] = locationMessage
                    }
                }
            }
        
        locationListeners[userId] = listener
    }
    
    private func updateLocation(_ location: CLLocation) {
        guard let currentUserId = Auth.auth().currentUser?.uid,
              let chatId = currentChatId else { return }
        
        let updateData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": Timestamp(date: Date())
        ]
        
        db.collection("chats")
            .document(chatId)
            .collection("locationSharing")
            .document(currentUserId)
            .updateData(updateData)
    }
    
    func stopListening(for userId: String) {
        locationListeners[userId]?.remove()
        locationListeners[userId] = nil
        activeLocationSharing[userId] = nil
    }
}

extension LocationSharingViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        updateLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error.localizedDescription
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .restricted, .denied:
            error = "Se requieren permisos de ubicación para compartir tu ubicación"
            if let chatId = currentChatId {
                stopSharingLocation(in: chatId)
            }
        default:
            break
        }
    }
} 
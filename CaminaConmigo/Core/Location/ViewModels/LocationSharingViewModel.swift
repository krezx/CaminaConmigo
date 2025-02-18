import Foundation
import CoreLocation
import FirebaseFirestore
import FirebaseAuth
import UIKit

class LocationSharingViewModel: NSObject, ObservableObject {
    @Published var activeLocationSharing: [String: LocationMessage] = [:]
    @Published var error: String?
    
    private let db = Firestore.firestore()
    private let locationManager = CLLocationManager()
    private var locationListeners: [String: ListenerRegistration] = [:]
    private var currentChatId: String?
    
    private let defaults = UserDefaults.standard
    private let isSharing = "isLocationSharing"
    private let activeChatId = "activeLocationChatId"
    
    override init() {
        super.init()
        setupLocationManager()
        restoreSharingStateIfNeeded()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        
        // Verificar si tenemos los permisos necesarios
        if #available(iOS 14.0, *) {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
            case .restricted, .denied:
                error = "Se requieren permisos de ubicación para compartir tu ubicación"
            default:
                break
            }
        } else {
            locationManager.requestAlwaysAuthorization()
        }
        
        // Registrar para notificaciones de la app
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    private func configureBackgroundUpdates() {
        if let _ = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String],
           locationManager.authorizationStatus == .authorizedAlways {
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
        }
    }
    
    private func restoreSharingStateIfNeeded() {
        if defaults.bool(forKey: isSharing),
           let chatId = defaults.string(forKey: activeChatId) {
            currentChatId = chatId
            UserDefaults.standard.set(true, forKey: "isShareingLocation")
            configureBackgroundUpdates()
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc private func appDidEnterBackground() {
        if locationManager.authorizationStatus == .authorizedAlways && currentChatId != nil {
            let content = UNMutableNotificationContent()
            content.title = "Compartiendo ubicación"
            content.body = "Tu ubicación se está compartiendo en segundo plano"
            content.sound = .none
            
            let request = UNNotificationRequest(
                identifier: "locationSharing",
                content: content,
                trigger: nil
            )
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func startSharingLocation(in chatId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        currentChatId = chatId
        defaults.set(true, forKey: isSharing)
        defaults.set(chatId, forKey: activeChatId)
        UserDefaults.standard.set(true, forKey: "isShareingLocation")
        
        let authStatus = locationManager.authorizationStatus
        guard authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways else {
            error = "Se requieren permisos de ubicación para compartir tu ubicación"
            return
        }
        
        configureBackgroundUpdates()
        locationManager.startUpdatingLocation()
        
        if let location = locationManager.location {
            let locationMessage = LocationMessage(
                id: UUID().uuidString,
                senderId: currentUserId,
                timestamp: Date(),
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                isActive: true
            )
            
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
        currentChatId = nil
        
        // Limpiar UserDefaults
        defaults.set(false, forKey: isSharing)
        defaults.removeObject(forKey: activeChatId)
        UserDefaults.standard.set(false, forKey: "isShareingLocation")
        
        // Remover notificación si existe
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["locationSharing"])
        
        db.collection("chats")
            .document(chatId)
            .collection("locationSharing")
            .document(currentUserId)
            .updateData([
                "isActive": false,
                "timestamp": Timestamp(date: Date())
            ])
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
    
    func stopListening(for userId: String) {
        locationListeners[userId]?.remove()
        locationListeners[userId] = nil
        activeLocationSharing[userId] = nil
    }
}

extension LocationSharingViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last,
              let chatId = currentChatId ?? defaults.string(forKey: activeChatId),
              let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let updateData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": Timestamp(date: Date()),
            "isActive": true
        ]
        
        db.collection("chats")
            .document(chatId)
            .collection("locationSharing")
            .document(currentUserId)
            .updateData(updateData)
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
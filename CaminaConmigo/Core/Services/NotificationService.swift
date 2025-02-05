import Foundation
import UIKit
import FirebaseMessaging
import UserNotifications
import FirebaseCore

class NotificationService: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    
    override init() {
        super.init()
        
        // Configurar los delegados
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }
    
    func requestAuthorization() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                if granted {
                    print("Permisos de notificación concedidos")
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else if let error = error {
                    print("Error al solicitar permisos de notificación: \(error.localizedDescription)")
                }
            }
        )
    }
    
    // MARK: - MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("FCM token: \(token)")
        // Aquí puedes enviar el token a tu servidor
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        // Aquí puedes manejar la interacción con la notificación
        completionHandler()
    }
} 

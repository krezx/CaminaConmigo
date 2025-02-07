//
//  CaminaConmigoApp.swift
//  CaminaConmigo
//
//  Created by a on 20-01-25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import FirebaseMessaging

// Clase para manejar la navegación global de la app
class NavigationState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var selectedReportId: String? = nil
    @Published var shouldShowReport: Bool = false
}

/// Clase AppDelegate que conforma el protocolo UIApplicationDelegate.
/// Maneja los eventos de la aplicación, como su inicio y la gestión de URL.
class AppDelegate: NSObject, UIApplicationDelegate {
    
    /// Método que se llama al terminar de lanzar la aplicación.
    /// Configura Firebase al iniciar la aplicación.
    ///
    /// - Parameters:
    ///   - application: La aplicación que se está lanzando.
    ///   - launchOptions: Opciones de lanzamiento de la aplicación.
    /// - Returns: Un valor booleano que indica si la inicialización fue exitosa.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        NotificationService.shared.requestAuthorization()
        return true
    }
  
    /// Método que se llama cuando la aplicación recibe una URL.
    /// Permite que Google Sign-In maneje el retorno de la autenticación.
    ///
    /// - Parameters:
    ///   - app: La aplicación que recibe la URL.
    ///   - url: La URL que se recibió.
    ///   - options: Opciones relacionadas con la apertura de la URL.
    /// - Returns: Un valor booleano que indica si se manejó la URL correctamente.
    func application(_ app: UIApplication,
                    open url: URL,
                    options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication,
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

/// Estructura principal de la aplicación que conforma el protocolo App.
@main
struct CaminaConmigoApp: App {
    @StateObject var authViewModel = AuthenticationViewModel() // Inicializa el ViewModel de autenticación.
    @StateObject var navigationState = NavigationState() // Estado de navegación global
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate // Asocia el AppDelegate con la aplicación.
    
    /// Cuerpo principal de la aplicación que define su escena.
    var body: some Scene {
        WindowGroup { // Grupo de ventanas para la interfaz de usuario.
            Group {
                // Verifica si hay una sesión de usuario activa o si el modo invitado está habilitado.
                if authViewModel.userSession != nil || authViewModel.isGuestMode {
                    TabViewCustom() // Muestra la vista principal de la aplicación.
                } else {
                    LoginView() // Muestra la vista de inicio de sesión.
                }
            }
            .environmentObject(authViewModel) // Proporciona el ViewModel de autenticación al entorno.
            .environmentObject(navigationState) // Proporciona el estado de navegación al entorno.
            .preferredColorScheme(.light) // Establece el esquema de color preferido a claro.
        }
    }
}

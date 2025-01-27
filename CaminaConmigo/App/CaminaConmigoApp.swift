//
//  CaminaConmigoApp.swift
//  CaminaConmigo
//
//  Created by a on 20-01-25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
  
  func application(_ app: UIApplication,
                  open url: URL,
                  options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
  }
}

@main
struct CaminaConmigoApp: App {
    @StateObject var authViewModel = AuthenticationViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.userSession != nil || authViewModel.isGuestMode {
                    TabViewCustom()
                } else {
                    LoginView()
                }
            }
            .environmentObject(authViewModel)
            .preferredColorScheme(.light)
        }
    }
}

import Foundation
import Firebase
import GoogleSignIn
import FirebaseAuth

class AuthenticationViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isGuestMode: Bool = false
    
    init() {
        self.userSession = Auth.auth().currentUser
    }
    
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Configurar Google Sign In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first,
              let rootViewController = await window.rootViewController else {
            throw AuthError.noRootViewController
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.tokenError
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            let authResult = try await Auth.auth().signIn(with: credential)
            self.userSession = authResult.user
            
        } catch {
            throw AuthError.signInError
        }
    }
    
    func signInAsGuest() {
        self.isGuestMode = true
        self.userSession = nil
    }
    
    func signOut() {
        if isGuestMode {
            self.isGuestMode = false
        } else {
            do {
                try Auth.auth().signOut()
                self.userSession = nil
                GIDSignIn.sharedInstance.signOut()
            } catch {
                print("Error al cerrar sesión: \(error.localizedDescription)")
            }
        }
    }
}

enum AuthError: Error {
    case noRootViewController
    case tokenError
    case signInError
} 

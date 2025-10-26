import SwiftUI

@main
struct onFraudApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MainTabView() // Usuario ya logueado → va directo a la app
            } else {
                OnboardingView() // Usuario nuevo o cerrado sesión
            }
        }
    }
}

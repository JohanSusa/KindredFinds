import UIKit
import ParseSwift
import CoreLocation // Keep if needed elsewhere, though not directly used here now

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // --- Parse Initialization (Keep As Is) ---
        ParseSwift.initialize(applicationId: "qlVWxnDmNExWx03iUprYnZOPZaoB1mPw9wfYo6Rx", // Replace with your App ID
                              clientKey: "6rLHT1l6MUGcuMdfGh2VrjsFKrizmALj8Sp1S56h",      // Replace with your Client Key
                              serverURL: URL(string: "https://parseapi.back4app.com")!)

        // Example: Register custom ParseObject subclasses if needed
        // FoundItem.register() // No longer needed with ParseSwift direct conformance
        // User.register()      // No longer needed with ParseSwift direct conformance

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
    }
}

// Removed GameScore struct as it wasn't used in the main flow

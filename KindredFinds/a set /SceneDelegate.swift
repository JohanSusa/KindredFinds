import UIKit
import ParseSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Create the UIWindow
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // Add observers for login/logout events
        NotificationCenter.default.addObserver(forName: .userDidLogin, object: nil, queue: .main) { [weak self] _ in
            self?.transitionToMainApp()
        }
        NotificationCenter.default.addObserver(forName: .userDidLogout, object: nil, queue: .main) { [weak self] _ in
            self?.transitionToLogin()
        }

        // Check initial login state
        if User.current != nil {
            print("✅ User already logged in.")
            transitionToMainApp()
        } else {
            print("👤 No user logged in.")
            transitionToLogin()
        }

        window.makeKeyAndVisible()
    }

    private func transitionToLogin() {
        print("🔄 Transitioning to Login Screen")
        let loginVC = LoginViewController()
        // Embed in a Navigation Controller for potential push to SignUp
        let navController = UINavigationController(rootViewController: loginVC)
        navController.navigationBar.prefersLargeTitles = true // Example of styling
        window?.rootViewController = navController
    }

    private func transitionToMainApp() {
        print("🔄 Transitioning to Main App Screen (Feed)")
        let mainTabBarVC = MainTabBarController() // Use a Tab Bar Controller
        window?.rootViewController = mainTabBarVC
    }

    // --- Logout Logic (Moved here for better separation) ---
    func handleLogout() {
        User.logout { result in
            DispatchQueue.main.async { // Ensure UI updates on main thread
                switch result {
                case .success:
                    print("✅ User logged out successfully.")
                    // Notification will trigger transitionToLogin()
                    NotificationCenter.default.post(name: .userDidLogout, object: nil)
                case .failure(let error):
                    print("❌ Log out error: \(error)")
                    // Optionally show an alert to the user on the current screen before transitioning
                    self.showErrorAlert(title: "Logout Failed", message: error.localizedDescription)
                    // Still transition to login even if server logout fails locally
                     NotificationCenter.default.post(name: .userDidLogout, object: nil)
                }
            }
        }
    }

     private func showErrorAlert(title: String, message: String) {
        // Find the currently visible view controller to present the alert
        guard let rootVC = window?.rootViewController else { return }
        var visibleVC = rootVC
        if let presentedVC = rootVC.presentedViewController {
            visibleVC = presentedVC
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        visibleVC.present(alertController, animated: true)
    }


    // --- Other Scene Delegate Methods (Mostly boilerplate) ---

    func sceneDidDisconnect(_ scene: UIScene) { }
    func sceneDidBecomeActive(_ scene: UIScene) { }
    func sceneWillResignActive(_ scene: UIScene) { }
    func sceneWillEnterForeground(_ scene: UIScene) { }
    func sceneDidEnterBackground(_ scene: UIScene) { }
}

// MARK: - Notification Names
extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLoginNotification")
    static let userDidLogout = Notification.Name("userDidLogoutNotification")
}

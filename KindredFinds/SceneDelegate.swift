import UIKit
import ParseSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // Identifiers for programmatic navigation
    private enum NavigationFlow {
        case login
        case mainApp
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Create a new UIWindow
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // Add observers for login/logout events
        NotificationCenter.default.addObserver(forName: Notification.Name("login"), object: nil, queue: .main) { [weak self] _ in
            print("✅ Login Notification Received")
            self?.transitionToState(.mainApp)
        }

        NotificationCenter.default.addObserver(forName: Notification.Name("logout"), object: nil, queue: .main) { [weak self] _ in
            print("✅ Logout Notification Received")
            self?.logOut() // Trigger logout logic which includes UI transition
        }

        // Check initial login state
        if User.current != nil {
            print("User already logged in, transitioning to main app")
            transitionToState(.mainApp)
        } else {
            print("No user logged in, transitioning to login")
            transitionToState(.login)
        }

        // Make the window visible
        window.makeKeyAndVisible()
    }

    private func transitionToState(_ state: NavigationFlow) {
        let rootViewController: UIViewController

        switch state {
        case .login:
            // Instantiate LoginViewController programmatically and wrap in Nav Controller
            let loginVC = LoginViewController()
            // Set up a transition or pass necessary dependencies if needed
            rootViewController = UINavigationController(rootViewController: loginVC)
            print("Setting root to Login Navigation Controller")

        case .mainApp:
            // Instantiate ItemListViewController programmatically and wrap in Nav Controller
            let itemListVC = ItemListViewController()
            // Set up a transition or pass necessary dependencies if needed
            rootViewController = UINavigationController(rootViewController: itemListVC)
             print("Setting root to Item List Navigation Controller")
        }

        // Set the root view controller and animate the transition
        if let window = self.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = rootViewController
            }, completion: nil)
        } else {
             print("Error: Window not available for transition")
             self.window?.rootViewController = rootViewController // Fallback
        }
    }

    private func logOut() {
        User.logout { [weak self] result in
            DispatchQueue.main.async { // Ensure UI update is on main thread
                switch result {
                case .success:
                    print("✅ Successfully logged out")
                    self?.transitionToState(.login)
                case .failure(let error):
                    print("❌ Log out error: \(error)")
                    // Optionally show an alert to the user about the logout failure
                    // For safety, still transition to login even if server logout fails locally
                    self?.transitionToState(.login)
                }
            }
        }
    }

    // Other SceneDelegate methods (keep default implementations)
    func sceneDidDisconnect(_ scene: UIScene) { }
    func sceneDidBecomeActive(_ scene: UIScene) { }
    func sceneWillResignActive(_ scene: UIScene) { }
    func sceneWillEnterForeground(_ scene: UIScene) { }
    func sceneDidEnterBackground(_ scene: UIScene) { }
}

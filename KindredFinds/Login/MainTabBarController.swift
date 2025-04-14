import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }

    private func setupTabs() {
        let feedVC = FeedViewController()
        let feedNav = UINavigationController(rootViewController: feedVC)
        feedNav.tabBarItem = UITabBarItem(title: "Feed",
                                          image: UIImage(systemName: "house"),
                                          selectedImage: UIImage(systemName: "house.fill"))
         feedNav.navigationBar.prefersLargeTitles = false // Keep feed title small


        // --- Post Tab (Placeholder/Modal Trigger) ---
       
        let postPlaceholderVC = UIViewController()
         postPlaceholderVC.tabBarItem = UITabBarItem(title: "Post",
                                          image: UIImage(systemName: "plus.app"),
                                          selectedImage: UIImage(systemName: "plus.app.fill"))


        // --- Profile Tab (Example - Add if needed) ---
        // let profileVC = ProfileViewController() // Create this VC if needed
        // let profileNav = UINavigationController(rootViewController: profileVC)
        // profileNav.tabBarItem = UITabBarItem(title: "Profile",
        //                                    image: UIImage(systemName: "person.circle"),
        //                                    selectedImage: UIImage(systemName: "person.circle.fill"))

        
        viewControllers = [feedNav, postPlaceholderVC]

        // Set delegate to handle tab selection (for presenting the Post VC)
        self.delegate = self
    }

    private func setupAppearance() {
        // Customize Tab Bar Appearance (Optional)
        tabBar.tintColor = .label // Color for selected items (adapts)
        tabBar.unselectedItemTintColor = .secondaryLabel
        tabBar.backgroundColor = .systemBackground

        // Customize Navigation Bar Appearance Globally (Optional)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        // Customize title text attributes if desired
        // appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        // appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance // For landscape
    }

     private func presentPostViewController() {
        let postVC = PostViewController()
        let postNav = UINavigationController(rootViewController: postVC)
        postNav.modalPresentationStyle = .fullScreen // Or .automatic
        present(postNav, animated: true, completion: nil)
    }
}

// MARK: - UITabBarControllerDelegate
extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Check if the selected view controller is the placeholder for the "Post" tab
        if viewController is UINavigationController { // Regular VCs in Nav Controllers
             return true
        } else if viewController == viewControllers?[1] { // Check if it's the specific placeholder VC instance
            print("Post tab selected - presenting PostViewController modally.")
            presentPostViewController()
            return false // Prevent switching to the empty placeholder tab
        }
        return true // Allow selection for other tabs
    }
}

import UIKit
import ParseSwift

class LoginViewController: UIViewController {

    // --- Programmatic UI Elements ---
    private let usernameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let passwordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(onLoginTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled() // Use modern configuration
        return button
    }()

     private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Don't have an account? Sign Up", for: .normal)
        button.addTarget(self, action: #selector(onSignUpLinkTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // --- Lifecycle ---
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDismissKeyboardGesture() // Add gesture recognizer
        title = "Login" // Set navigation bar title
        view.backgroundColor = .systemBackground // Set background color
    }

    // --- UI Setup ---
    private func setupUI() {
        view.addSubview(usernameField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)

        // Layout constraints
        NSLayoutConstraint.activate([
            // Username Field
            usernameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            usernameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            usernameField.heightAnchor.constraint(equalToConstant: 44),

            // Password Field
            passwordField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 15),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordField.heightAnchor.constraint(equalToConstant: 44),

            // Login Button
            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 30),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            // Sign Up Button
             signUpButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
             signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // --- Actions ---
    @objc private func onLoginTapped() {
        print("Login button tapped")
        view.endEditing(true) // Dismiss keyboard

        guard let username = usernameField.text,
              let password = passwordField.text,
              !username.isEmpty,
              !password.isEmpty else {
            showMissingFieldsAlert()
            return
        }

        // Disable button during login attempt
        loginButton.isEnabled = false
        loginButton.configuration?.showsActivityIndicator = true // Show loading indicator

        User.login(username: username, password: password) { [weak self] result in
            // Re-enable button and hide indicator on main thread
             DispatchQueue.main.async {
                self?.loginButton.isEnabled = true
                self?.loginButton.configuration?.showsActivityIndicator = false
             }

            switch result {
            case .success(let user):
                print("✅ Successfully logged in as user: \(user.username ?? "N/A")")
                // Post notification on the main thread AFTER the async block finishes
                 DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
                 }
            case .failure(let error):
                print("❌ Login failed: \(error)")
                 DispatchQueue.main.async {
                     self?.showAlert(description: error.localizedDescription)
                 }
            }
        }
    }

     @objc private func onSignUpLinkTapped() {
         print("Sign Up link tapped")
         let signUpVC = SignUpViewController()
         // Present modally or push if embedded in a nav controller
         navigationController?.pushViewController(signUpVC, animated: true)
     }


    // --- Alerts (Keep As Is) ---
    private func showAlert(title: String = "Unable to Log in", description: String?) {
        // Run on main thread
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: description ?? "Unknown error", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            self.present(alertController, animated: true)
        }
    }

    private func showMissingFieldsAlert() {
        showAlert(title: "Opps...", description: "We need all fields filled out in order to log you in.")
    }

    // --- Keyboard Handling ---
     private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

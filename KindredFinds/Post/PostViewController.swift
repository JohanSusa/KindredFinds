import UIKit
import ParseSwift
import PhotosUI // For PHPickerViewController
import CoreLocation // For CLLocationManager

class FoundItemViewController: UIViewController, CLLocationManagerDelegate, PHPickerViewControllerDelegate, UITextViewDelegate {

    // --- Programmatic UI Elements ---
    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true // Allow tapping to pick image
        imageView.image = UIImage(systemName: "photo.on.rectangle.angled") // Initial placeholder
        imageView.tintColor = .gray
        return imageView
    }()

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = "Enter item description here..." // Placeholder text
        textView.textColor = .lightGray
        return textView
    }()

     // Navigation Bar Buttons
    private lazy var shareButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(onShareTapped))
    }()

    private lazy var cancelButton: UIBarButtonItem = {
         return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancelTapped))
     }()


    // --- Properties ---
    private var pickedImage: UIImage? {
        didSet {
            // Enable share button only if an image is picked AND description is not empty/placeholder
            updateShareButtonState()
             // Update image view
            previewImageView.image = pickedImage ?? UIImage(systemName: "photo.on.rectangle.angled")
            previewImageView.contentMode = (pickedImage != nil) ? .scaleAspectFit : .center // Adjust content mode
            previewImageView.tintColor = (pickedImage != nil) ? .clear : .gray
        }
    }

    private var hasEnteredDescription: Bool {
        return descriptionTextView.textColor != .lightGray && !descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }


    // Location Properties
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?

    // --- Lifecycle ---
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        setupLocationServices()
        setupDismissKeyboardGesture()
        addTapGestureToImageView()

        // Set initial state
        shareButton.isEnabled = false
        descriptionTextView.delegate = self // Set delegate for placeholder handling
    }

    // --- Setup ---
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(previewImageView)
        view.addSubview(descriptionTextView)

        let padding: CGFloat = 16

        NSLayoutConstraint.activate([
            // Preview Image View
            previewImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            previewImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            previewImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            previewImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6), // Adjust height as needed

            // Description Text View
            descriptionTextView.topAnchor.constraint(equalTo: previewImageView.bottomAnchor, constant: padding),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 150) // Adjust height as needed
        ])
    }

     private func setupNavigation() {
        title = "Post Found Item"
        navigationItem.rightBarButtonItem = shareButton
        navigationItem.leftBarButtonItem = cancelButton
    }

     private func addTapGestureToImageView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onImageTapped))
        previewImageView.addGestureRecognizer(tapGesture)
    }

    // --- Location Services ---
    private func setupLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters // Balance accuracy and power

        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            print("ℹ️ Requesting location permission...")
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            print("✅ Location permission already granted. Requesting location update.")
            locationManager.requestLocation() // Request a one-time location update
        } else {
            print("⚠️ Location permission denied or restricted.")
            // Optionally inform user why location is useful
        }
    }

    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("ℹ️ Location authorization status changed to: \(status.rawValue)")
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            print("✅ Permission granted/changed. Requesting location.")
            locationManager.requestLocation()
        } else if status == .denied || status == .restricted {
            print("⚠️ User denied or restricted location access.")
            currentLocation = nil // Clear location if permission revoked
            // Optionally show an alert explaining the impact
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            currentLocation = location
            // No need to stop updates for requestLocation(), it stops automatically.
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle specific errors (like kCLErrorDenied, kCLErrorLocationUnknown) if needed
        print("❌ Location manager failed with error: \(error.localizedDescription)")
        currentLocation = nil // Clear location on failure
        // Ignore location unknown errors initially as it might resolve
        if (error as? CLError)?.code != .locationUnknown {
             // Show alert for significant errors like permission denial
             showAlert(description: "Could not get location: \(error.localizedDescription)")
        }
    }

    // --- Image Picking ---
    @objc private func onImageTapped() {
         print("Image view tapped - showing picker")
         presentImagePicker()
     }

     private func presentImagePicker() {
        var config = PHPickerConfiguration()
        config.filter = .images // Only allow images
        config.preferredAssetRepresentationMode = .current // Use most appropriate representation
        config.selectionLimit = 1 // Only one image
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else {
             print("No image provider found or cannot load UIImage.")
             return
        }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
             guard let self = self else { return }

            DispatchQueue.main.async { // Perform UI updates on main thread
                if let error = error {
                    print("❌ Error loading image from picker: \(error.localizedDescription)")
                    self.showAlert(description: error.localizedDescription)
                    return
                }

                guard let image = object as? UIImage else {
                     print("❌ Could not cast loaded object to UIImage.")
                    self.showAlert(description: "Could not load image.")
                    return
                }

                print("🖼️ Image selected.")
                self.pickedImage = image // This triggers the didSet and updates UI/button state
                 // Request location update again after image selection if permitted
                 if self.locationManager.authorizationStatus == .authorizedWhenInUse || self.locationManager.authorizationStatus == .authorizedAlways {
                    self.locationManager.requestLocation()
                }
            }
        }
    }

    // --- Sharing ---
    @objc private func onShareTapped() {
        print("Share button tapped")
        view.endEditing(true) // Dismiss keyboard

         // --- Validation ---
        guard let image = pickedImage else {
            showAlert(description: "Please select an image for the item.")
            return
        }
         guard hasEnteredDescription, let description = descriptionTextView.text else {
             showAlert(description: "Please enter a description for the item.")
            return
         }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
             showAlert(description: "Could not process image data.")
             return
         }
         guard let currentUser = User.current else {
            showAlert(title: "Error", description: "You must be logged in to share.")
            // Potentially trigger logout/login flow here
            return
         }

        // --- Disable UI during save ---
        setLoadingState(true)


        // --- Create Parse Objects ---
        let imageFile = ParseFile(name: "item_image.jpg", data: imageData) // Consider more unique names

        var newItem = FoundItem()
        newItem.imageFile = imageFile
        newItem.descriptionText = description
        newItem.user = currentUser

        if let location = currentLocation {
            do {
                newItem.location = try ParseGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                 print("✅ Attaching location to item: \(newItem.location!)")
            } catch {
                 print("⚠️ Could not create ParseGeoPoint: \(error)")
                 // Decide if saving without location is acceptable or show error
            }
        } else {
            print("⚠️ No location data available to attach.")
             // Decide if saving without location is acceptable
        }

        // --- Save to Parse ---
         print("Attempting to save item...")
        newItem.save { [weak self] result in
             guard let self = self else { return }
            // Perform UI updates on main thread
            DispatchQueue.main.async {
                 print("Save attempt finished.")
                 // Re-enable UI
                 self.setLoadingState(false)

                switch result {
                case .success(let savedItem):
                     print("✅ Item Saved! \(savedItem.objectId ?? "N/A")")
                    // Dismiss the view controller after successful save
                     self.dismiss(animated: true, completion: nil)
                     // Optional: Post a notification if the list view needs to refresh immediately
                     // NotificationCenter.default.post(name: Notification.Name("newItemPosted"), object: nil)

                case .failure(let error):
                    self.showAlert(description: "Failed to save item: \(error.localizedDescription)")
                    print("❌ Failed to save item: \(error)")
                }
            }
        }
    }

     @objc private func onCancelTapped() {
         print("Cancel button tapped")
         // Add confirmation if user has entered data
         if pickedImage != nil || hasEnteredDescription {
             let alert = UIAlertController(title: "Discard Item?", message: "Are you sure you want to discard this found item post?", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { _ in
                 self.dismiss(animated: true, completion: nil)
             }))
             alert.addAction(UIAlertAction(title: "Keep Editing", style: .cancel, handler: nil))
             present(alert, animated: true)
         } else {
             dismiss(animated: true, completion: nil) // Dismiss directly if nothing entered
         }
     }


     private func setLoadingState(_ isLoading: Bool) {
         shareButton.isEnabled = !isLoading && pickedImage != nil && hasEnteredDescription
         cancelButton.isEnabled = !isLoading
         // Optionally show an activity indicator
         if isLoading {
             let activityIndicator = UIActivityIndicatorView(style: .medium)
             let barButton = UIBarButtonItem(customView: activityIndicator)
             navigationItem.rightBarButtonItem = barButton
             activityIndicator.startAnimating()
         } else {
             navigationItem.rightBarButtonItem = shareButton // Restore original button
         }
         view.isUserInteractionEnabled = !isLoading // Prevent interaction during save
     }


     private func updateShareButtonState() {
        shareButton.isEnabled = pickedImage != nil && hasEnteredDescription
    }

    // --- Alerts ---
    private func showAlert(title: String = "Oops...", description: String?) {
        // Ensure alert is shown on the main thread
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: "\(description ?? "Please try again...")", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            // Make sure the view controller can present the alert
            if self.isViewLoaded && self.view.window != nil {
                 self.present(alertController, animated: true)
            } else {
                print("⚠️ Alert cannot be presented: View not in window hierarchy.")
                // Handle cases where the view might be dismissing
            }
        }
    }


    // --- Keyboard Handling ---
     private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Allow taps on controls like image view
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

     // --- TextView Delegate (for Placeholder) ---
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .label // Use standard text color
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter item description here..."
            textView.textColor = .lightGray
        }
         updateShareButtonState() // Check state when editing ends
    }

     func textViewDidChange(_ textView: UITextView) {
         updateShareButtonState() // Check state on every change
     }

}

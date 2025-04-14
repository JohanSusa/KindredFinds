import UIKit
import ParseSwift
import MapKit // Import MapKit
import Alamofire // For image loading
import AlamofireImage
import CoreLocation // For CLGeocoder

class ItemDetailViewController: UIViewController {

    // Data property to hold the item passed from the list view
    var foundItem: FoundItem? {
        didSet {
            // Update UI when the item is set (ensure view is loaded)
            if isViewLoaded {
                configureView()
            }
        }
    }

    // --- Programmatic UI Elements ---
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill // Fill the top area
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 0 // Allow multiple lines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

     private let userInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Location UI
     private let locationSectionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.text = "Location Found"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true // Hide until location confirmed
        return label
    }()

    private let locationTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.layer.cornerRadius = 8
        map.layer.masksToBounds = true
        map.isScrollEnabled = false // Disable map scroll within scroll view
        map.isZoomEnabled = false
        return map
    }()

    // Comments Section (Placeholder)
    private let commentsSectionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.text = "Comments"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let commentsPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .placeholderText
        label.text = "(Comments feature not yet implemented)"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    // --- Properties ---
    private var imageDataRequest: DataRequest?
    private let geocoder = CLGeocoder()

    // --- Lifecycle ---
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureView() // Configure with initial data if available
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Cancel pending requests if the view disappears
        imageDataRequest?.cancel()
        if geocoder.isGeocoding {
            geocoder.cancelGeocode()
        }
    }

    // --- UI Setup ---
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Item Details" // Set navigation title

        // Add Scroll View
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Add elements to Content View
        contentView.addSubview(itemImageView)
        contentView.addSubview(userInfoLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(locationSectionLabel)
        contentView.addSubview(locationTextLabel)
        contentView.addSubview(mapView)
        contentView.addSubview(commentsSectionLabel)
        contentView.addSubview(commentsPlaceholderLabel)


        let padding: CGFloat = 16
        let sectionSpacing: CGFloat = 20

        // --- Layout Constraints ---
        NSLayoutConstraint.activate([
            // Scroll View constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Content View constraints (pinned to scroll view edges and width matching view)
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor), // Crucial for vertical scrolling

            // Item Image View (Top)
            itemImageView.topAnchor.constraint(equalTo: contentView.topAnchor), // Pin to top of content view
            itemImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            itemImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            itemImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.65), // Make image reasonably tall

             // User Info Label
            userInfoLabel.topAnchor.constraint(equalTo: itemImageView.bottomAnchor, constant: padding),
            userInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            userInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),


            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: userInfoLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            // Location Section Label
            locationSectionLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: sectionSpacing),
            locationSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            locationSectionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),


            // Location Text Label
            locationTextLabel.topAnchor.constraint(equalTo: locationSectionLabel.bottomAnchor, constant: 8),
            locationTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            locationTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

             // Map View
            mapView.topAnchor.constraint(equalTo: locationTextLabel.bottomAnchor, constant: 8),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            mapView.heightAnchor.constraint(equalToConstant: 200), // Fixed height for the map


            // Comments Section Label
            commentsSectionLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: sectionSpacing),
            commentsSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            commentsSectionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),


            // Comments Placeholder Label
            commentsPlaceholderLabel.topAnchor.constraint(equalTo: commentsSectionLabel.bottomAnchor, constant: 8),
            commentsPlaceholderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            commentsPlaceholderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            commentsPlaceholderLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding) // Pin to bottom of content view
        ])

        // Hide location elements initially
        locationSectionLabel.isHidden = true
        locationTextLabel.isHidden = true
        mapView.isHidden = true
    }

    // --- Data Configuration ---
    private func configureView() {
        guard let item = foundItem else {
             print("⚠️ ItemDetailViewController: FoundItem data is nil.")
            // Optionally show an error state in the UI
             descriptionLabel.text = "Error loading item details."
            return
        }

        // Configure Image
        itemImageView.image = UIImage(systemName: "photo") // Placeholder
        if let imageFile = item.imageFile, let imageUrl = imageFile.url {
            imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                 guard let self = self else { return }
                switch response.result {
                case .success(let image):
                    self.itemImageView.image = image
                case .failure(let error):
                    if !error.isExplicitlyCancelledError {
                         print("❌ Error fetching detail image: \(error.localizedDescription)")
                    }
                }
            }
        }

         // Configure User Info
        var userDateText = "Posted"
        if let username = item.user?.username {
            userDateText += " by \(username)"
        }
        if let date = item.createdAt {
             userDateText += " on \(DateFormatter.postFormatter.string(from: date))"
        }
        userInfoLabel.text = userDateText


        // Configure Description
        descriptionLabel.text = item.descriptionText ?? "No description provided."

        // Configure Location (Text and Map)
        if let geoPoint = item.location {
            locationSectionLabel.isHidden = false
            locationTextLabel.isHidden = false
            mapView.isHidden = false
            locationTextLabel.text = "Fetching address..."

            let location = CLLocation(latitude: geoPoint.latitude, longitude: geoPoint.longitude)

            // Update Map
             updateMap(with: location.coordinate)

            // Update Text via Geocoding
            geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
                guard let self = self else { return }
                DispatchQueue.main.async { // Ensure UI update on main thread
                    if let error = error {
                         print("❌ Detail Reverse geocode failed: \(error.localizedDescription)")
                        self.locationTextLabel.text = "Address unavailable"
                    } else if let placemark = placemarks?.first {
                        var locationString = ""
                        if let name = placemark.name, !name.contains("Unnamed Road") { locationString += "\(name)\n" } // Include street name if available
                        if let city = placemark.locality { locationString += city }
                        if let state = placemark.administrativeArea {
                            if !locationString.isEmpty && placemark.locality != nil { locationString += ", " } // Add comma if city exists
                            locationString += state
                        }
                        if let postalCode = placemark.postalCode { locationString += " \(postalCode)" }
                        if locationString.isEmpty { locationString = "Address details not found" }
                        self.locationTextLabel.text = locationString.trimmingCharacters(in: .whitespacesAndNewlines) // Clean up string
                    } else {
                        self.locationTextLabel.text = "Address details not found"
                    }
                }
            }
        } else {
             // Hide location section if no data
             locationSectionLabel.isHidden = true
             locationTextLabel.isHidden = true
             mapView.isHidden = true
        }

        // Configure Comments (Placeholder)
        // In a real app, you'd fetch comments related to the 'foundItem.objectId' here
    }


     private func updateMap(with coordinate: CLLocationCoordinate2D) {
        // Remove existing annotations
        mapView.removeAnnotations(mapView.annotations)

        // Create annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
         annotation.title = "Item Found Here" // Optional title for the pin

        // Add annotation to map
        mapView.addAnnotation(annotation)

        // Set map region
        let regionRadius: CLLocationDistance = 500 // Show ~500m radius around the pin
        let coordinateRegion = MKCoordinateRegion(center: coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: false) // Set region without animation initially
    }

}

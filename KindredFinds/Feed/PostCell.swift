import UIKit
import ParseSwift
import CoreLocation // For FoundItemCell geocoding context

class ItemListViewController: UIViewController {

    // --- Programmatic UI Elements ---
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        // Register the programmatic cell class
        tableView.register(FoundItemCell.self, forCellReuseIdentifier: FoundItemCell.identifier)
        return tableView
    }()

    private let refreshControl = UIRefreshControl()

    // --- Data ---
    private var items = [FoundItem]() {
        didSet {
            // Reload table view data any time the items variable gets updated.
            tableView.reloadData()
        }
    }

    // Infinite Scroll properties
    private var isLoadingMore = false
    private let queryLimit = 10 // Number of items to fetch per batch

    // --- Lifecycle ---
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        setupTableView()
        setupRefreshControl()

        // Initial data fetch
        queryItems(refreshing: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Optional: Refresh data if needed when view appears,
        // or rely on pull-to-refresh/initial load.
        // queryItems() // Be cautious about triggering too many fetches
    }

    // --- Setup ---
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)

        // Layout constraints for table view
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

     private func setupNavigation() {
        title = "Found Items" // Set navigation title
        // Add (+) button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddTapped))
        // Add Logout button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(onLogOutTapped))
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension // Use auto-layout height
        tableView.estimatedRowHeight = 400 // Provide estimate for performance
        tableView.allowsSelection = true // Enable selection for detail view
    }

     private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    // --- Data Fetching ---
    private func queryItems(refreshing: Bool = false, skip: Int = 0) {
        print("Querying items... Refreshing: \(refreshing), Skip: \(skip)")

        // Prevent multiple simultaneous loads
        guard !isLoadingMore else {
            print("⚠️ Already loading more items. Aborting query.")
            if refreshing { refreshControl.endRefreshing() } // Stop spinner if it was a refresh
            return
        }

        // Construct the query for FoundItem
        let query = FoundItem.query()
            .include("user") // Include the user data
            .order([.descending("createdAt")]) // Order by newest first
            .limit(self.queryLimit) // Limit the number of results
            .skip(skip) // Skip results for pagination

        // Indicate loading state
        isLoadingMore = true // Mark as loading
        if refreshing {
             print("Starting refresh control animation")
            refreshControl.beginRefreshing()
        } else if skip > 0 {
             print("Showing loading indicator for pagination (conceptual)")
            // Optionally, show a loading indicator at the bottom (e.g., table view footer)
        }

        // Find items asynchronously
        query.find { [weak self] result in
            guard let self = self else { return }

            // Perform UI updates on main thread
            DispatchQueue.main.async {
                 print("Query finished. Updating UI.")
                // Stop loading indicators
                self.refreshControl.endRefreshing()
                self.isLoadingMore = false // Mark as done loading THIS batch

                // Hide footer loading indicator if used

                switch result {
                case .success(let fetchedItems):
                    if refreshing {
                        // If refreshing, replace existing items
                        self.items = fetchedItems
                        print("✅ Refreshed \(fetchedItems.count) items.")
                    } else {
                        // If loading more, append to existing items
                        self.items.append(contentsOf: fetchedItems)
                        print("✅ Loaded \(fetchedItems.count) more items. Total: \(self.items.count)")
                    }

                    // If fewer items than the limit were returned, we've likely reached the end
                     if fetchedItems.count < self.queryLimit {
                        print("ℹ️ Reached end of items or fetched less than limit.")
                        // Optionally disable further loading attempts, though setting isLoadingMore=true
                        // when fetchedItems.count is 0 might be enough
                         self.isLoadingMore = true // Consider setting this to true only if fetchedItems.count == 0
                    } else {
                         self.isLoadingMore = false // Ready to load more if needed
                     }


                case .failure(let error):
                    self.showAlert(description: "Error fetching items: \(error.localizedDescription)")
                    print("❌ Error fetching items: \(error)")
                     // Ensure loading flag is reset on error to allow retries
                     self.isLoadingMore = false
                }
            }
        }
    }

    // --- Actions ---
     @objc private func onAddTapped() {
        print("Add button tapped")
        let foundItemVC = FoundItemViewController()
        // You might want to wrap this in a navigation controller if it needs its own bar
        let navController = UINavigationController(rootViewController: foundItemVC)
        present(navController, animated: true, completion: nil) // Present modally
    }

    @objc private func handleRefresh(_ sender: UIRefreshControl) {
        print("Pull to refresh triggered")
        queryItems(refreshing: true, skip: 0) // Fetch the latest items, replacing current ones
    }

    @objc private func onLogOutTapped() {
        print("Logout button tapped")
        showConfirmLogoutAlert()
    }

    // --- Alerts (Keep As Is) ---
    private func showConfirmLogoutAlert() {
         DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Log out of your account?", message: nil, preferredStyle: .alert)
            let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
                NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertController.addAction(logOutAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
         }
    }

    private func showAlert(title: String = "Oops...", description: String? = nil) {
         DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: "\(description ?? "Please try again...")", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            self.present(alertController, animated: true)
         }
    }
}

// MARK: - UITableViewDataSource
extension ItemListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FoundItemCell.identifier, for: indexPath) as? FoundItemCell else {
            print("Error: Could not dequeue FoundItemCell")
            return UITableViewCell() // Should not happen if registered correctly
        }
        cell.configure(with: items[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ItemListViewController: UITableViewDelegate {
    // Infinite Scrolling Trigger
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Check if the second to last row is about to be displayed and if we are not already loading
        // (Trigger slightly before the absolute end for smoother loading)
        let triggerIndex = items.count - 2
        if indexPath.row >= triggerIndex && indexPath.row > 0 && !isLoadingMore && items.count >= queryLimit { // Ensure not loading and there might be more
            print("🏁 Reached near bottom (row \(indexPath.row)/\(items.count-1)), attempting to load more...")
            let nextSkip = items.count
            queryItems(refreshing: false, skip: nextSkip)
        }
    }

     // Handle Row Selection - Navigate to Detail View
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select row \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true) // Deselect visually

        let selectedItem = items[indexPath.row]
        let detailVC = ItemDetailViewController()
        detailVC.foundItem = selectedItem // Pass the selected item data

        // Push the detail view controller onto the navigation stack
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

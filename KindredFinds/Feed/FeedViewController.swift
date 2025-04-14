
import UIKit
import ParseSwift
import CoreLocation


class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var posts = [Post]() {
        didSet {
            tableView.reloadData()
        }
    }
    //Infinite Scroll and Refresh
        private let refreshControl = UIRefreshControl()
        private var isLoadingMore = false
        private let limit = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        // Configure Refresh Control
                refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
                tableView.refreshControl = refreshControl
            
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        queryPosts()
    }

    private func queryPosts(refreshing: Bool = false, skip: Int = 0) {
            let query = Post.query()
                .include("user")
                .order([.descending("createdAt")])
                .limit(limit)
                .skip(skip)

            if refreshing {
                refreshControl.beginRefreshing()
            } else {
                // Optionally, show a loading indicator at the bottom
                // ( add a footer view to the table view)
            }
            isLoadingMore = true

            query.find { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.isLoadingMore = false

                    switch result {
                    case .success(let fetchedPosts):
                        if refreshing {
                            self.posts = fetchedPosts
                             print("✅ Refreshed \(fetchedPosts.count) posts.")
                        } else {
                            self.posts.append(contentsOf: fetchedPosts)
                             print("✅ Loaded \(fetchedPosts.count) more posts. Total: \(self.posts.count)")
                        }
                        
                         if fetchedPosts.count < self.limit {
                            print("ℹ️ Reached end of posts.")
                            self.isLoadingMore = true
                        }


                    case .failure(let error):
                        self.showAlert(description: "Error fetching posts: \(error.localizedDescription)")
                        print("❌ Error fetching posts: \(error)")
                    }
                }
            }
        }
    
    @objc func handleRefresh(_ sender: UIRefreshControl) {
            queryPosts(refreshing: true) // Fetch the latest posts, replacing current ones
        }

    @IBAction func onLogOutTapped(_ sender: Any) {
        showConfirmLogoutAlert()
    }

    // MARK: - Alerts

    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(title: "Log out of your account?", message: nil, preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FeedViewController: UITableViewDelegate {
    // Infinite Scrolling Trigger
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == posts.count - 1 && !isLoadingMore {
            print("🏁 Reached bottom, attempting to load more...")
            let nextSkip = posts.count
            queryPosts(refreshing: false, skip: nextSkip)
        }
    }
}

//
//  FeedView.swift
//  KindredFinds

//  Created by NATANAEL  MEDINA & Johan Susa
//
import SwiftUI
import ParseSwift

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel() // Use a ViewModel

    var body: some View {
        NavigationStack { //stack if navigation is needed within
            Group {
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    ProgressView("Loading Feed...")
                } else if viewModel.posts.isEmpty {
                     Text("No lost items posted yet.\nBe the first!")
                         .font(.headline)
                         .foregroundColor(.gray)
                         .multilineTextAlignment(.center)
                         .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) { // Increased spacing between cards
                            ForEach(viewModel.posts) { post in // Use objectId implicitly via Identifiable
                                NavigationLink(destination: PostDetailView(post: post)) {
                                    PostCellView(
                                        name: post.caption ?? "Untitled Item",
                                        location: post.address ?? "Location not specified",
                                        imageURL: post.imageFile?.url
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical) // Add padding top/bottom of stack
                        .padding(.horizontal)
                    }
                    .refreshable {
                        await viewModel.fetchPosts()
                    }
                }
            }
            .navigationTitle("Lost Items Feed")
            .task {
                if viewModel.posts.isEmpty {
                    await viewModel.fetchPosts()
                }
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                 Button("OK") { }
            } message: {
                 Text(viewModel.errorMessage)
            }
        }
    }
}

// ViewModel for FeedView Logic
@MainActor
class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    func fetchPosts() async {
        isLoading = true
        showErrorAlert = false

        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])

        do {
            let retrievedPosts = try await query.find()
            self.posts = retrievedPosts
            print("✅ Successfully fetched \(retrievedPosts.count) posts.")
        } catch {
            print("❌ Error fetching posts: \(error.localizedDescription)")
            self.errorMessage = "Failed to load feed: \(error.localizedDescription)"
            self.showErrorAlert = true
        }
        isLoading = false
    }
}


// Preview
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}

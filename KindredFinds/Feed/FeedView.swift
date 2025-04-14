//
//  FeedView.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA  on 4/13/25.
//

import SwiftUI
import ParseSwift

struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var navigateToNewPost = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(posts, id: \.objectId) { post in
                        PostCellView(
                            name: post.caption ?? "Untitled",
                            location: post.user?.username ?? "Unknown",
                            imageURL: post.imageFile?.url
                        ).padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: PostView(onSubmit: { newPost in
                        posts.insert(newPost, at: 0)
                    })) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                fetchPosts()
            }
        }
    }

    private func fetchPosts() {
        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])

        query.find { result in
            switch result {
            case .success(let retrievedPosts):
                posts = retrievedPosts
            case .failure(let error):
                print("Error fetching posts: \(error.localizedDescription)")
            }
        }
    }
    
}



#Preview {
    FeedView()
}





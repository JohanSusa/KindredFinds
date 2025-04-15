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
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(posts, id: \.objectId) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            PostCellView(
                                name: post.caption ?? "Untitled",
                                location: post.address ?? "no location assinged",
                                imageURL: post.imageFile?.url
                            )
                            .padding(.horizontal, 0.5)
                        }
                    }
                }
            }
            .onAppear(){
                fetchPosts()
            }
            .refreshable {
                fetchPosts()
            }
        }
        .navigationBarBackButtonHidden(true)
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





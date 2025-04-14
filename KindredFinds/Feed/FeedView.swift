//
//  FeedView.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA  on 4/13/25.
//

import SwiftUI

struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var navigateToNewPost = false
    
    init(posts: [Post] = []) {
        _posts = State(initialValue: posts)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(posts) { post in
                        PostCellView(name: post.name, location: post.location, imageName: post.image)
                    }
                }
                .padding()
            }
            .navigationTitle("Fed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: PostView(onSubmit: { newPost in
                        posts.insert(newPost, at: 0)
                    })) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}


#Preview {
    FeedView(posts: [
        Post(name: "Golden Hour", location: "Key Biscayne", image: UIImage(systemName: "sun.max.fill")!),
        Post(name: "Evening Stroll", location: "South Beach", image: UIImage(systemName: "cloud.sun.fill")!)
    ])
}






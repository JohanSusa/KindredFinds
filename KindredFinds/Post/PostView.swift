//
//  PostView.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA  on 4/13/25.
//

import SwiftUI

struct PostView: View {
    
    @State private var name = ""
    @State private var location = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @Environment(\.dismiss) private var dismiss

    var onSubmit: (Post) -> Void

    var body: some View {
        
        VStack(spacing: 16) {
            
            
            Button("Add Photo") {
                showImagePicker = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            TextField("Name of the Picture", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Location", text: $location)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Post") {
                guard let selectedImage else { return }
                let post = Post(name: name, location: location, image: selectedImage)
                onSubmit(post)
                dismiss()
            }
            .disabled(selectedImage == nil || name.isEmpty || location.isEmpty)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            // Display Image if Selected
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("New Post")
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
}



#Preview {
    NavigationView {
        PostView(onSubmit: { post in
            print("Post created: \(post.name) at \(post.location)")
        })
    }
}


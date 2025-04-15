//
//  PostView.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA  on 4/13/25.
//

import SwiftUI
import ParseSwift

struct PostView: View {
    
    @State private var name = ""
    @State private var location = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var isSaving = false
    @Environment(\.dismiss) private var dismiss

    var onSubmit: (Post) -> Void

    var body: some View {
        
        VStack(spacing: 10) {
            
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
                savePost()
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
    
    private func savePost() {
        guard let selectedImage = selectedImage,
              let imageData = selectedImage.jpegData(compressionQuality: 0.1),
              let currentUser = User.current else{
            print("Missing requared data")
            return
        }
        
        isSaving = true
        
        let photFile = ParseFile(name: "Photo.jpg", data: imageData)
        
        photFile.save() { result in
            switch result {
            case .success(let savedFile):
                var post = Post()
                post.caption = name
                post.user = currentUser
                post.imageFile = savedFile
                
                post.save { result in
                    DispatchQueue.main.async {
                        isSaving = false
                        switch result {
                        case .success(let savedPost):
                            print("Post saved: \(savedPost)")
                            dismiss()
                        case .failure(let error):
                            print("Error saving post: \(error.localizedDescription)")
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    isSaving = false
                    print("Error saving image: \(error.localizedDescription)")
                }
            }
        }
                
              
    }
    
}

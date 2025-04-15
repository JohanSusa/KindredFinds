//
//  PostView.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA  on 4/13/25.
//

import SwiftUI
import ParseSwift
import CoreLocation


struct PostView: View {
    
    @State private var name = ""
    @State private var description: String = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var isSaving = false
    @State private var imageLocation: CLLocation?

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

            TextField("Name of the Item found", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Item Description", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Post") {
                savePost()
            }
            .disabled(selectedImage == nil || name.isEmpty || description.isEmpty)
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
            ImagePicker(image: $selectedImage, location: $imageLocation)
        }
    }
    
    private func savePost() {
        guard let selectedImage = selectedImage,
              let imageData = selectedImage.jpegData(compressionQuality: 0.1),
              let currentUser = User.current else {
            print("Missing required data")
            return
        }

        isSaving = true
        let photoFile = ParseFile(name: "Photo.jpg", data: imageData)

        photoFile.save { result in
            switch result {
            case .success(let savedFile):
                var post = Post()
                post.caption = name
                post.user = currentUser
                post.imageFile = savedFile
                post.itemDescription = description

                var acl = ParseACL()
                acl.publicRead = true
                post.ACL = acl
                post.user?.ACL = acl

                // Location-based save
                if let loc = imageLocation {
                    do {
                        post.geoPoint = try ParseGeoPoint(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
                        print("📍 Saving post with location: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")

                        fetchAddress(for: loc) { addressString in
                            post.address = addressString

                            post.save { result in
                                DispatchQueue.main.async {
                                    isSaving = false
                                    switch result {
                                    case .success(_):
                                        print("Post saved with address: \(addressString)")
                                        dismiss()
                                    case .failure(let error):
                                        print("Error saving post: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }

                    } catch {
                        print("Error creating ParseGeoPoint: \(error.localizedDescription)")
                        isSaving = false
                    }

                } else {
                    // No location — save immediately
                    post.save { result in
                        DispatchQueue.main.async {
                            isSaving = false
                            switch result {
                            case .success(_):
                                print("Post saved without location")
                                dismiss()
                            case .failure(let error):
                                print("Error saving post: \(error.localizedDescription)")
                            }
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

    
    func fetchAddress(for location: CLLocation, completion: @escaping (String) -> Void) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let parts = [placemark.name, placemark.locality, placemark.administrativeArea]
                let fullAddress = parts.compactMap { $0 }.joined(separator: ", ")
                completion(fullAddress)
            } else {
                completion("Unknown location")
            }
        }
    }

    
}

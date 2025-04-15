//
//  PostView.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA & Johan Susa
//
import SwiftUI
import ParseSwift
import CoreLocation
import PhotosUI

struct PostView: View {
    @Binding var selectedTab: Int

    // State variables for the post form
    @State private var itemName: String = ""
    @State private var itemDescription: String = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var isSaving = false
    @State private var imageLocation: CLLocation?

    // State for showing alerts and tracking post success
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var postSucceeded = false

    var body: some View {
         NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // - Image Selection Area -
                    VStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(10)
                                .onTapGesture { showImagePicker = true }
                        } else {
                             Button {
                                 showImagePicker = true
                             } label: {
                                 ZStack {
                                     RoundedRectangle(cornerRadius: 10)
                                         .fill(Color(.systemGray5))
                                         .frame(height: 200)
                                     VStack {
                                         Image(systemName: "photo.on.rectangle.angled")
                                             .font(.largeTitle)
                                             .foregroundColor(.gray)
                                         Text("Tap to add photo")
                                             .font(.headline)
                                             .foregroundColor(.gray)
                                     }
                                 }
                             }
                             .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.bottom)


                    // -Item Name TextField -
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Item Name").font(.headline).foregroundColor(.secondary)
                        TextField("e.g., Blue Backpack, Set of Keys", text: $itemName)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }


                    // -Item Description TextEditor
                    VStack(alignment: .leading, spacing: 4) {
                         Text("Description").font(.headline).foregroundColor(.secondary)
                         ZStack(alignment: .topLeading) {
                             // Placeholder Text - shown only when itemDescription is empty
                             if itemDescription.isEmpty {
                                 Text("Enter item description...")
                                     .foregroundColor(.gray.opacity(0.7))
                                     .padding(.horizontal, 5)
                                     .padding(.vertical, 8)
                                     .allowsHitTesting(false)
                             }

                             // The actual TextEditor
                             TextEditor(text: $itemDescription)
                                 .frame(height: 150)
                                 .scrollContentBackground(.hidden)
                                 .padding(5)
                         }
                         .background(Color(.systemGray6))
                         .cornerRadius(8)
                         .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Post Lost Item")
             .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                 // --- Toolbar Items ---
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button(action: savePost) {
                         if isSaving {
                             ProgressView()
                                 .progressViewStyle(CircularProgressViewStyle(tint: .primary)) // Adjust tint if needed
                         } else {
                             Text("Post")
                                 .fontWeight(.bold)
                         }
                     }
                     .disabled(selectedImage == nil || itemName.isEmpty || itemDescription.isEmpty || isSaving)
                 }
            }
            .sheet(isPresented: $showImagePicker) {
                 ImagePicker(image: $selectedImage, location: $imageLocation)
            }
            .alert("Post Item", isPresented: $showAlert) {
                 Button("OK") {
                     if postSucceeded {
                         selectedTab = 0
                         postSucceeded = false
                     }
                 }
            } message: {
                 Text(alertMessage)
            }
        }
         .navigationViewStyle(.stack)
    }

    // --- Function to save the post ---
    private func savePost() {
        guard let selectedImage = selectedImage,
              let imageData = selectedImage.jpegData(compressionQuality: 0.8),
              let currentUser = User.current else {
            postSucceeded = false
            alertMessage = "Image and user information are required."
            showAlert = true
            print("❌ Missing required data: Image or User")
            return
        }
        guard !itemName.isEmpty else {
             postSucceeded = false
             alertMessage = "Please enter a name for the item."
             showAlert = true
             return
        }
        // Ensure description isn't empty
        guard !itemDescription.isEmpty else {
             postSucceeded = false
             alertMessage = "Please enter a description for the item."
             showAlert = true
             return
        }

        isSaving = true
        postSucceeded = false
        let photoFile = ParseFile(name: "photo.jpg", data: imageData)

        Task {
             do {
                 let savedFile = try await photoFile.save()
                 print("✅ Image file saved.")

                 // Create the new Post object
                 var post = Post()
                 post.caption = itemName
                 post.itemDescription = itemDescription
                 post.user = currentUser
                 post.imageFile = savedFile

                 // Set Access Control List (ACL) for security
                
                 var acl = ParseACL()
                 acl.publicRead = true
                 acl.setWriteAccess(user: currentUser, value: true)
                 post.ACL = acl

                 if let loc = imageLocation {
                     do {
                         post.geoPoint = try ParseGeoPoint(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
                         let fetchedAddress = await fetchAddress(for: loc)
                         post.address = fetchedAddress
                         print("📍 Saving with location: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
                         print("🗺️ Fetched address: \(fetchedAddress)")
                     } catch {
                         print("⚠️ Error creating ParseGeoPoint: \(error.localizedDescription)")
                     }
                 } else {
                     post.address = "Location not available"
                     print("📍 No location data found in image.")
                 }

                 _ = try await post.save()
                 print("✅ Post saved successfully!")

                 // SUCCESS HANDLING & STATE RESET
                 isSaving = false
                 alertMessage = "Item posted successfully!"
                 postSucceeded = true

                 // Reset the state variables to clear
                 self.itemName = ""
                 self.itemDescription = ""
                 self.selectedImage = nil
                 self.imageLocation = nil
                 // ---------------------------------------

                 showAlert = true

             } catch {
                 // --- Error Handling ---
                 print("❌ Error saving post: \(error.localizedDescription)")
                 isSaving = false
                 postSucceeded = false
                 alertMessage = "Failed to post item: \(error.localizedDescription)"
                 showAlert = true
             }
         }
    }

    // --- Helper function to get address from coordinates ---
    func fetchAddress(for location: CLLocation) async -> String {
        let geocoder = CLGeocoder()
        do {
            // Perform reverse geocoding
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                let parts = [placemark.name, placemark.locality, placemark.administrativeArea, placemark.country]
                return parts.compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")
            } else {
                return "Address not found"
            }
        } catch {
            print("⚠️ Geocoding error: \(error.localizedDescription)")
            return "Error finding address"
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
       
        PostView(selectedTab: .constant(1))
    }
}

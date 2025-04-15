//
//  PostDetailView.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA & Johan Susa
//
import SwiftUI
import ParseSwift
import MapKit // Import MapKit

struct PostDetailView: View {
    let post: Post

     @State private var mapRegion: MKCoordinateRegion?
     @State private var mapAnnotationItems: [MapAnnotationItem] = [] //  map pin

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Image Section
                AsyncImage(url: post.imageFile?.url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                             Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 300)
                             ProgressView()
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                    case .failure:
                        ZStack {
                             Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 300)
                             Image(systemName: "photo.fill")
                                .resizable().scaledToFit().frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                 .frame(height: 300)
                 .clipped()


                // Item Title / Caption
                Text(post.caption ?? "Item Detail")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 8)

                // Posted By Information
                HStack {
                     Image(systemName: "person.fill")
                         .foregroundColor(.secondary)
                     Text("Posted by: \(post.user?.username ?? "Unknown User")")
                         .font(.subheadline)
                         .foregroundColor(.secondary)
                }

                // Item Description Section
                Divider()
                Text("Description")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(post.itemDescription ?? "No description provided.")
                    .font(.body)

                // Location Section
                if post.geoPoint != nil || post.address != nil {
                    Divider()
                    Text("Location")
                         .font(.title3)
                         .fontWeight(.semibold)

                    // Display Text Address (prioritize fetched address)
                    if let address = post.address, !address.isEmpty, address != "Location not available", address != "Error finding address", address != "Address not found" {
                         HStack {
                             Image(systemName: "mappin.and.ellipse")
                             Text(address)
                                 .font(.callout)
                         }
                    } else if let geo = post.geoPoint {
                        // Fallback to coordinates if address is missing/invalid
                         HStack {
                             Image(systemName: "location.circle")
                             Text("Lat: \(String(format: "%.4f", geo.latitude)), Lon: \(String(format: "%.4f", geo.longitude))")
                                 .font(.caption)
                                 .foregroundColor(.gray)
                         }
                    } else {
                         Text("Location details not available.")
                             .font(.callout)
                             .foregroundColor(.gray)
                    }


                     // Display Map
                     if let region = mapRegion {
                         Map(coordinateRegion: .constant(region), annotationItems: mapAnnotationItems) { item in
                             MapMarker(coordinate: item.coordinate, tint: .red) // Use a simple marker
                         }
                         .frame(height: 250)
                         .cornerRadius(10)
                         .padding(.top, 8)
                     }
                 }

                Spacer()
            }
            .padding()
        }
         .navigationTitle(post.caption ?? "Item Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupMapRegion()
        }
    }

    private func setupMapRegion() {
         guard let geoPoint = post.geoPoint else { return }

         let coordinate = CLLocationCoordinate2D(
             latitude: geoPoint.latitude,
             longitude: geoPoint.longitude
         )

         mapRegion = MKCoordinateRegion(
             center: coordinate,
             span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // Adjust zoom level
         )

        // Create map pin
         mapAnnotationItems = [MapAnnotationItem(coordinate: coordinate)]
    }
}

// Simple struct for map annotations (needs to be Identifiable)
struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// Preview requires a Post object
struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePost: Post = {
            var post = Post()
            post.objectId = "mock123"
            post.caption = "Preview Item Name"
            post.itemDescription = "This is a detailed description of the item found. It was located near the main fountain and looks quite old."
            post.address = "123 Preview Street, Mocktown, USA"
            post.createdAt = Date()
             var user = User()
             user.username = "PreviewUser"
             post.user = user
             do {
                post.geoPoint = try ParseGeoPoint(latitude: 34.0522, longitude: -118.2437)
             } catch { print("Error creating preview geopoint") }
            
            return post
        }()

        NavigationStack {
            PostDetailView(post: samplePost)
        }
    }
}

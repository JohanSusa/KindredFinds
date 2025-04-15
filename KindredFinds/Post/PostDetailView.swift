//
//  PostDetailView.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA  on 4/15/25.
//

import SwiftUI
import ParseSwift
import MapKit

struct PostDetailView: View {
    
    @State private var address: String = "Loading address..."

    let post: Post
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                if let url = post.imageFile?.url {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 250)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 250)
                                .clipped()
                                .cornerRadius(12)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 250)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                Text(post.caption ?? "No Description")
                    .font(.body)
                    .padding(.top, 8)

                Text("Posted by: \(post.user?.username ?? "Unknown")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(post.itemDescription ?? "missing description")
                    .font(.body)
                    
                Text("📍 Location: \(String(describing: post.address))")
                        .font(.caption)
                        .foregroundColor(.gray)

                // Location Text
                if let loc = post.geoPoint {
                    Text("📍 Location: \(loc.latitude), \(loc.longitude)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .onAppear {
                            let coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
                            fetchAddress(from: coordinate)
                        }
                }
                
                // Display Map
                if let loc = post.geoPoint {
                    Map(coordinateRegion: .constant(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude),
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    ), interactionModes: [])
                    .frame(height: 200)
                    .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Post Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func fetchAddress(from coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                self.address = "Address not found"
            } else if let placemark = placemarks?.first {
                let parts = [placemark.name, placemark.locality, placemark.administrativeArea]
                self.address = parts.compactMap { $0 }.joined(separator: ", ")
            }
        }
    }

}

//#Preview {
//    PostDetailView(post: Post(
//        objectId: "preview-id",
//        caption: "Found keys near parking lot",
//        user: User(username: "sampleuser"),
//        imageFile: nil
//    ))
//}

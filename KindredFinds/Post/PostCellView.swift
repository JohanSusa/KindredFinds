//
//  PostCellView.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA  on 4/13/25.
//

import SwiftUI

struct PostCellView: View {
    let name: String
    let location: String
    let imageURL: URL?

    var body: some View {
        VStack(alignment: .leading) {
            // Name of the picture
            Text(name)
                .font(.headline)
                .padding(.horizontal, 5)

            // Location (user or actual location string)
            Text(location)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 5)
            
            // Image from URL using AsyncImage
            
            
            // Image
            if let url = imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(minHeight: 250, maxHeight: 250)
                .clipped()
            }

        }
    }
}

#Preview {
    PostCellView(
        name: "Golden Hour",
        location: "Key Biscayne",
        imageURL: URL(string: "https://via.placeholder.com/400x200.png?text=Sample+Image")
    )
}
//https://via.placeholder.com/400x200.png?text=Sample+Image

//
//  PostCellView.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA & Johan Susa
//
import SwiftUI

struct PostCellView: View {
    let name: String
    let location: String
    let imageURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // No spacing needed if image fills width

            // Image Section
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ZStack { // Use ZStack for placeholder content
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 250)
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                case .failure:
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 250)
                        Image(systemName: "photo.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                    }
                @unknown default:
                    EmptyView()
                }
            }

            // Text Content Section
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .lineLimit(1)

                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(location)
                        .font(.subheadline) // Consistent size
                        .foregroundColor(.secondary) // Use secondary color for less emphasis
                        .lineLimit(1)
                }
            }
            .padding([.horizontal, .bottom], 12)
            .padding(.top, 8)

        }
        // Card Styling
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .overlay(
             RoundedRectangle(cornerRadius: 12)
                 .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )

    }
}

// Preview
struct PostCellView_Previews: PreviewProvider {
    static var previews: some View {
        PostCellView(
            name: "Found Keys Near Park",
            location: "Central Park, Near South Entrance",
            imageURL: URL(string: "https://via.placeholder.com/600x400.png?text=Sample+Item")
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

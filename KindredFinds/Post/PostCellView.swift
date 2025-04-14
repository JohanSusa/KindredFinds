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
    let imageName: UIImage // name of an image asset

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Name of the picture
            Text(name)
                .font(.headline)

            // Location
            Text(location)
                .font(.subheadline)
                .foregroundColor(.gray)

            // Image
            Image(uiImage: imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()
                .cornerRadius(12)
        }
        .padding()
    }
}


#Preview {
    PostCellView(name: "Wallet",
                 location: "Florida",
                 imageName: UIImage(named: "yourImageName") ?? UIImage(systemName: "photo")!)
}

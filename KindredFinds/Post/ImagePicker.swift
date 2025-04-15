//
//  ImagePicker.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA & Johan Susa
//
import SwiftUI
import PhotosUI
import CoreLocation

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var location: CLLocation?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.selectionLimit = 1 // Only allow one image selection
        config.filter = .images // Only show images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()

            guard let result = results.first else {
                return
            }

            let itemProvider = result.itemProvider

             // load the Image
             if itemProvider.canLoadObject(ofClass: UIImage.self) {
                 itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                     if let image = object as? UIImage {
                         DispatchQueue.main.async {
                             self?.parent.image = image
                             print("✅ Image loaded from picker.")
                         }
                     } else if let error = error {
                          print("❌ Error loading image: \(error.localizedDescription)")
                     }
                 }
             } else {
                  print("⚠️ Cannot load UIImage object from item provider.")
             }


             // Fetch Location Metadata
             if let assetId = result.assetIdentifier {
                 print("ℹ️ Asset Identifier found: \(assetId)")
                 let fetchOptions = PHFetchOptions()

                 let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: fetchOptions)

                 if let asset = assets.firstObject {
                     DispatchQueue.main.async {
                         if let loc = asset.location {
                             self.parent.location = loc
                             print("📍 Location found in photo metadata: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
                         } else {
                              self.parent.location = nil 
                              print("❌ No location metadata found in this photo.")
                         }
                     }
                 } else {
                      print("⚠️ Could not fetch PHAsset with identifier: \(assetId)")
                      DispatchQueue.main.async { self.parent.location = nil }
                 }
             } else {
                 print("⚠️ No assetIdentifier available for location lookup.")
                 DispatchQueue.main.async { self.parent.location = nil }
             }
        }
    }
}

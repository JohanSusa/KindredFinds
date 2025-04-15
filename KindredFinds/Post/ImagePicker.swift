//
//  ImagePicker.swift
//  KindredFinds
//
//  Created by NATANAEL  MEDINA  on 4/13/25.
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
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let result = results.first else {
                parent.presentationMode.wrappedValue.dismiss()
                return
            }

            let itemProvider = result.itemProvider

            // Load UIImage
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.image = image
                        }
                    }
                }
            }

            // Load CLLocation from PHAsset
            if let assetId = result.assetIdentifier {
                let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
                if let asset = assets.firstObject {
                    DispatchQueue.main.async {
                        if let loc = asset.location {
                            print("📍 Location from photo: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
                            self.parent.location = loc
                        } else {
                            print("❌ No location metadata found in photo.")
                        }
                    }
                }
            } else {
                print("❌ No assetIdentifier available.")
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


////
////  ImagePicker.swift
////  KindredFinds
////
////  Created by NATANAEL  MEDINA  on 4/13/25.
////
//
//import Foundation
//import SwiftUI
//import UIKit
//import Photos
//import CoreLocation
//import ImageIO
//
//struct ImagePicker: UIViewControllerRepresentable {
//    @Binding var image: UIImage?
//    @Binding var location: CLLocation?
//    @Environment(\.presentationMode) private var presentationMode
//
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator
//        picker.sourceType = .photoLibrary // or .camera
//        picker.mediaTypes = ["public.image"]
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//        let parent: ImagePicker
//
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController,
//                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let image = info[.originalImage] as? UIImage {
//                parent.image = image
//            }
//
//            if let asset = info[.phAsset] as? PHAsset {
//                if let location = asset.location {
//                    print("📸 Location extracted from photo: \(location.coordinate.latitude), \(location.coordinate.longitude)")
//                    parent.location = location
//                } else {
//                    print("❌ No location data in selected photo.")
//                    parent.location = nil
//                }
//            } else {
//                print("❌ No PHAsset found — photo might not have metadata.")
//                parent.location = nil
//            }
//
////            if let asset = info[.phAsset] as? PHAsset {
////                parent.location = asset.location
////            } else {
////                parent.location = nil
////            }
//
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//    }
//}
//
//

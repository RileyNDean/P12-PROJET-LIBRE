//
//  ImagePickerMulti.swift
//  My E-Dressing
//

import SwiftUI
import PhotosUI
import UIKit

/// PHPicker wrapper that returns multiple UIImages.
struct ImagePickerMulti: UIViewControllerRepresentable {
    var imagesHandler: (([PhotoItem]) -> Void)?
    @Binding var images: [UIImage]

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 6
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerMulti
        init(_ parent: ImagePickerMulti) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            let providers = results.map { $0.itemProvider }.filter { $0.canLoadObject(ofClass: UIImage.self) }
            var loaded: [UIImage] = []
            let group = DispatchGroup()
            providers.forEach { provider in
                group.enter()
                provider.loadObject(ofClass: UIImage.self) { obj, _ in
                    if let image = obj as? UIImage { loaded.append(image) }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                self.parent.images.append(contentsOf: loaded)
                let newItems = loaded.map { PhotoItem.new(image: $0) }
                self.parent.imagesHandler?(newItems)
            }
        }
    }
}

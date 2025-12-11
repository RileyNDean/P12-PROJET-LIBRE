//
// UIKit PHPicker wrapper returning multiple UIImages via a SwiftUI representable.
//

import SwiftUI
import PhotosUI
import UIKit

/// SwiftUI wrapper around `PHPickerViewController` that returns multiple `UIImage` objects.
struct ImagePickerMulti: UIViewControllerRepresentable {
    var imagesHandler: (([PhotoItem]) -> Void)?
    @Binding var images: [UIImage]

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 6 // 6 max
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = context.coordinator
        return vc
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

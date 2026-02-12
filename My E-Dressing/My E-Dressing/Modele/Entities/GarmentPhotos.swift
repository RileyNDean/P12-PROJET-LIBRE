//
//  GarmentPhotos.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import Foundation
import UIKit

/// Convenience helpers for accessing a garment's photos and loading images from disk.
extension Garment {
    var photoSet: Set<GarmentPhoto> { (photos as? Set<GarmentPhoto>) ?? [] }
    var orderedPhotos: [GarmentPhoto] { photoSet.sorted { $0.orderIndex < $1.orderIndex } }
    var primaryPhotoPath: String? { orderedPhotos.first?.path }

    var primaryImage: UIImage? {
        guard let path = primaryPhotoPath else { return nil }
        return MediaStore.shared.loadImage(at: path)
    }

    var allLoadedImages: [(id: UUID, image: UIImage)] {
        orderedPhotos.compactMap { photo in
            guard let path = photo.path,
                  let img = MediaStore.shared.loadImage(at: path),
                  let photoId = photo.id else { return nil }
            return (id: photoId, image: img)
        }
    }
}

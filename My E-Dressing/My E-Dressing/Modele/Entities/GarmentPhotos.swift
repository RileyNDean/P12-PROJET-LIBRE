//
//  GarmentPhotos.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import Foundation

extension Garment {
    var photoSet: Set<GarmentPhoto> { (photos as? Set<GarmentPhoto>) ?? [] }
    var orderedPhotos: [GarmentPhoto] { photoSet.sorted { $0.orderIndex < $1.orderIndex } }
    var primaryPhotoPath: String? { orderedPhotos.first?.path }
}

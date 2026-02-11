//
//  PhotoItem.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import SwiftUI
import CoreData

/// Represents either an existing persisted photo or a new one not yet saved.
enum PhotoItem: Identifiable, Equatable {
    case existing(photoObject: GarmentPhoto, thumbnail: UIImage)
    case new(image: UIImage)

    var id: String {
        switch self {
        case .existing(let photoObject, _):
            return photoObject.objectID.uriRepresentation().absoluteString
        case .new(let image):
            return String(ObjectIdentifier(image as AnyObject).hashValue)
        }
    }
}

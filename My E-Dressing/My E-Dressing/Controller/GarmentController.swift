//
//  GarmentController.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import CoreData
import UIKit

/// Handles CRUD operations for `Garment` entities and their photos.
final class GarmentController {

    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    // MARK: - Create

    /// Creates a garment with photos in a dressing.
    func create(
        in dressing: Dressing,
        title: String,
        brand: String?,
        color: String?,
        size: String?,
        category: String?,
        notes: String?,
        status: GarmentStatus,
        wearCount: Int32,
        photos: [UIImage]
    ) throws -> Garment {
        let validatedTitle = try Validation.nonEmpty(title, fieldName: String(localized: "title_required_placeholder"))
        guard !photos.isEmpty else { throw ValidationError(message: String(localized: "photo_required")) }

        let garment = Garment(context: managedObjectContext)
        garment.id = UUID()
        garment.title = validatedTitle
        garment.brand = brand?.nilIfEmpty
        garment.color = color?.nilIfEmpty
        garment.size = size?.nilIfEmpty
        garment.category = category?.nilIfEmpty
        garment.notes = notes?.nilIfEmpty
        garment.statusRaw = status.rawValue
        garment.createdAt = Date()
        garment.wearCount = wearCount
        garment.dressing = dressing

        _ = try attachPhotos(photos, to: garment, startingAt: 0)
        try managedObjectContext.save()
        return garment
    }

    // MARK: - Update

    /// Updates the metadata of an existing garment (no photo changes).
    func update(
        _ garment: Garment,
        title: String,
        brand: String?,
        color: String?,
        size: String?,
        category: String?,
        notes: String?,
        wearCount: Int32,
        status: GarmentStatus
    ) throws {
        garment.title = try Validation.nonEmpty(title, fieldName: String(localized: "title_required_placeholder"))
        garment.brand = brand?.nilIfEmpty
        garment.color = color?.nilIfEmpty
        garment.size = size?.nilIfEmpty
        garment.category = category?.nilIfEmpty
        garment.notes = notes?.nilIfEmpty
        garment.wearCount = wearCount
        garment.statusRaw = status.rawValue

        try validateHasAtLeastOnePhoto(garment)
        try managedObjectContext.save()
    }

    // MARK: - Photo Operations

    /// Adds new photos to a garment.
    func addPhotos(_ images: [UIImage], to garment: Garment) throws -> [GarmentPhoto] {
        let startIndex = garment.photoSet.count
        let createdPhotos = try attachPhotos(images, to: garment, startingAt: startIndex)
        try managedObjectContext.save()
        return createdPhotos
    }

    /// Also deletes the associated image files from disk.
    func removePhotos(_ photos: [GarmentPhoto], from garment: Garment) throws {
        let imagePathsToDelete: [String] = photos.compactMap { photo in photo.path }
        photos.forEach { managedObjectContext.delete($0) }
        try managedObjectContext.save()
        imagePathsToDelete.forEach { imagePath in MediaStore.shared.delete(at: imagePath) }
    }

    /// Reorders photos by updating their index.
    func reorderPhotos(_ orderedPhotos: [GarmentPhoto]) throws {
        for (index, photo) in orderedPhotos.enumerated() {
            photo.orderIndex = Int16(index)
        }
        try managedObjectContext.save()
    }

    // MARK: - Status / Wear Count / Delete

    /// Changes the garment status.
    func changeStatus(_ garment: Garment, to newStatus: GarmentStatus) throws {
        garment.statusRaw = newStatus.rawValue
        try managedObjectContext.save()
    }

    /// Increments wear count by one.
    func incrementWearCount(_ garment: Garment) throws {
        let currentWearCount = garment.value(forKey: "wearCount") as? Int32 ?? 0
        garment.setValue(currentWearCount + 1, forKey: "wearCount")
        try managedObjectContext.save()
    }

    /// Also cleans up associated image files from disk.
    func delete(_ garment: Garment) throws {
        let imagePaths: [String] = garment.photoSet.compactMap { $0.path }
        managedObjectContext.delete(garment)
        try managedObjectContext.save()
        imagePaths.forEach { MediaStore.shared.delete(at: $0) }
    }

    /// Throws if the garment has no photos.
    func validateHasAtLeastOnePhoto(_ garment: Garment) throws {
        if garment.photoSet.isEmpty {
            throw ValidationError(message: String(localized: "photo_required"))
        }
    }

    // MARK: - Private

    /// Saves images to disk and creates photo entities.
    private func attachPhotos(_ images: [UIImage], to garment: Garment, startingAt startingIndex: Int) throws -> [GarmentPhoto] {
        var createdPhotos: [GarmentPhoto] = []
        for (offset, image) in images.enumerated() {
            let imagePath = try MediaStore.shared.saveJPEG(image)
            let photo = GarmentPhoto(context: managedObjectContext)
            photo.id = UUID()
            photo.path = imagePath
            photo.createdAt = Date()
            photo.orderIndex = Int16(startingIndex + offset)
            photo.garment = garment
            createdPhotos.append(photo)
        }
        return createdPhotos
    }
}

//
//  GarmentController.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import CoreData
import UIKit

/// Coordinates CRUD operations for `Garment` entities and their photos.
///
/// This controller encapsulates business rules (e.g., at least one photo required) and
/// persists changes using an injected `NSManagedObjectContext`.
final class GarmentController {

    /// Creates a controller bound to a given Core Data context.
    /// - Parameter managedObjectContext: A main or background `NSManagedObjectContext`.
    init(managedObjectContext: NSManagedObjectContext) { self.managedObjectContext = managedObjectContext }

    // MARK: - Create (requires ≥1 photo)
    /// Creates a new `Garment` with at least one photo and persists it.
    /// - Parameters:
    ///   - dressing: Parent `Dressing` the garment belongs to.
    ///   - title: Non-empty title.
    ///   - brand: Optional brand.
    ///   - color: Optional color.
    ///   - size: Optional size.
    ///   - category: Optional category.
    ///   - notes: Optional notes.
    ///   - status: Initial `GarmentStatus`.
    ///   - photos: One or more images to attach.
    /// - Returns: The newly created `Garment`.
    /// - Throws: `ValidationError` if requirements are not met, or any Core Data save error.
    func create(
        in dressing: Dressing,
        title: String,
        brand: String?,
        color: String?,
        size: String?,
        category: String?,
        notes: String?,
        status: GarmentStatus,
        photos: [UIImage]
    ) throws -> Garment {
        let validatedTitle = try Validation.nonEmpty(title, field: "Title")
        guard !photos.isEmpty else { throw ValidationError(message: "At least one photo is required") }

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
        garment.dressing = dressing

        _ = try attachPhotos(photos, to: garment, startingAt: 0)
        try managedObjectContext.save()
        return garment
    }

    // MARK: - Update (metadata only)
    /// Updates garment metadata and enforces business rules.
    /// - Parameters:
    ///   - garment: The garment to update.
    ///   - title: New non-empty title.
    ///   - brand: Optional brand.
    ///   - color: Optional color.
    ///   - size: Optional size.
    ///   - category: Optional category.
    ///   - notes: Optional notes.
    ///   - status: New status.
    /// - Throws: `ValidationError` or any Core Data save error.
    func update(
        _ garment: Garment,
        title: String,
        brand: String?,
        color: String?,
        size: String?,
        category: String?,
        notes: String?,
        status: GarmentStatus
    ) throws {
        garment.title = try Validation.nonEmpty(title, field: "Title")
        garment.brand = brand?.nilIfEmpty
        garment.color = color?.nilIfEmpty
        garment.size = size?.nilIfEmpty
        garment.category = category?.nilIfEmpty
        garment.notes = notes?.nilIfEmpty
        garment.statusRaw = status.rawValue

        try validateHasAtLeastOnePhoto(garment)
        try managedObjectContext.save()
    }

    // MARK: - Photo operations
    /// Adds photos to a garment and persists the change.
    /// - Parameters:
    ///   - images: Images to attach.
    ///   - garment: Target garment.
    /// - Returns: The created `GarmentPhoto` objects.
    /// - Throws: Any Core Data save error.
    func addPhotos(_ images: [UIImage], to garment: Garment) throws -> [GarmentPhoto] {
        let startIndex = garment.photoSet.count
        let created = try attachPhotos(images, to: garment, startingAt: startIndex)
        try managedObjectContext.save()
        return created
    }

    /// Removes the given photos from a garment and deletes their files.
    /// - Parameters:
    ///   - photos: The photo objects to remove.
    ///   - garment: The parent garment.
    /// - Throws: Any Core Data save error.
    func removePhotos(_ photos: [GarmentPhoto], from garment: Garment) throws {
        let pathsToDelete: [String] = photos.compactMap { photo in photo.path }
        photos.forEach { managedObjectContext.delete($0) }
        try managedObjectContext.save()
        pathsToDelete.forEach { path in MediaStore.shared.delete(at: path) }
    }

    /// Reorders photos to match the provided sequence and persists the new order.
    /// - Parameter ordered: Photo objects in their desired order.
    /// - Throws: Any Core Data save error.
    func reorderPhotos(_ ordered: [GarmentPhoto]) throws {
        for (index, photo) in ordered.enumerated() {
            photo.orderIndex = Int16(index)
        }
        try managedObjectContext.save()
    }

    // MARK: - Status / Wear count / Delete
    /// Changes the garment status and persists the change.
    /// - Parameters:
    ///   - garment: The garment to update.
    ///   - newStatus: The new status.
    /// - Throws: Any Core Data save error.
    func changeStatus(_ garment: Garment, to newStatus: GarmentStatus) throws {
        garment.statusRaw = newStatus.rawValue
        try managedObjectContext.save()
    }

    /// Increments the wear count metric for analytics.
    /// - Parameter garment: The garment whose wear count to increment.
    /// - Throws: Any Core Data save error.
    func incrementWearCount(_ garment: Garment) throws {
        garment.setValue((garment.value(forKey: "wearCount") as? Int32 ?? 0) + 1, forKey: "wearCount")
        try managedObjectContext.save()
    }

    /// Deletes a garment and its images from storage.
    /// - Parameter garment: The garment to delete.
    /// - Throws: Any Core Data save error.
    func delete(_ garment: Garment) throws {
        let paths: [String] = garment.photoSet.compactMap { $0.path }
        managedObjectContext.delete(garment)
        try managedObjectContext.save()
        paths.forEach { MediaStore.shared.delete(at: $0) }
    }
    
    /// Validates that a garment has at least one photo.
    /// - Parameter garment: The garment to validate.
    /// - Throws: `ValidationError` when there are no photos.
    func validateHasAtLeastOnePhoto(_ garment: Garment) throws {
        if garment.photoSet.isEmpty {
            throw ValidationError(message: "At least one photo is required")
        }
    }

    // MARK: - Private
    /// Creates `GarmentPhoto` objects for images and associates them to a garment.
    /// - Parameters:
    ///   - images: The images to persist.
    ///   - garment: The target garment.
    ///   - index: Starting order index.
    /// - Returns: The created `GarmentPhoto` objects.
    /// - Throws: Any error thrown while saving images to disk.
    private func attachPhotos(_ images: [UIImage], to garment: Garment, startingAt index: Int) throws -> [GarmentPhoto] {
        var created: [GarmentPhoto] = []
        for (offset, image) in images.enumerated() {
            let path = try MediaStore.shared.saveJPEG(image)
            let photo = GarmentPhoto(context: managedObjectContext)
            photo.id = UUID()
            photo.path = path
            photo.createdAt = Date()
            photo.orderIndex = Int16(index + offset)
            photo.garment = garment
            created.append(photo)
        }
        return created
    }
}


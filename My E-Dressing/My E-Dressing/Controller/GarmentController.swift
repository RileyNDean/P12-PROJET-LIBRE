//
//  GarmentController.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import CoreData
import UIKit

/// Coordinates all CRUD operations for `Garment` and its photos.
final class GarmentController {

    private let managedObjectContext: NSManagedObjectContext
    init(managedObjectContext: NSManagedObjectContext) { self.managedObjectContext = managedObjectContext }

    // MARK: Create (≥1 photo required)
    @discardableResult
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

        try attachPhotos(photos, to: garment, startingAt: 0)
        try managedObjectContext.save()
        return garment
    }

    // MARK: Update (metadata only)
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

    // MARK: Photos ops
    @discardableResult
    func addPhotos(_ images: [UIImage], to garment: Garment) throws -> [GarmentPhoto] {
        let startIndex = garment.photoSet.count
        let created = try attachPhotos(images, to: garment, startingAt: startIndex)
        try managedObjectContext.save()
        return created
    }

    func removePhotos(_ photos: [GarmentPhoto], from garment: Garment) throws {
        let pathsToDelete: [String] = photos.compactMap { $0.path }
        photos.forEach { managedObjectContext.delete($0) }
        try managedObjectContext.save()
        pathsToDelete.forEach { MediaStore.shared.delete(at: $0) }
    }

    func reorderPhotos(_ ordered: [GarmentPhoto]) throws {
        for (index, photo) in ordered.enumerated() {
            photo.orderIndex = Int16(index)
        }
        try managedObjectContext.save()
    }

    // MARK: Status / Wear count / Delete
    func changeStatus(_ garment: Garment, to newStatus: GarmentStatus) throws {
        garment.statusRaw = newStatus.rawValue
        try managedObjectContext.save()
    }

    func incrementWearCount(_ garment: Garment) throws {
        garment.setValue((garment.value(forKey: "wearCount") as? Int32 ?? 0) + 1, forKey: "wearCount")
        try managedObjectContext.save()
    }

    func delete(_ garment: Garment) throws {
        let paths: [String] = garment.photoSet.compactMap { $0.path }
        managedObjectContext.delete(garment)
        try managedObjectContext.save()
        paths.forEach { MediaStore.shared.delete(at: $0) }
    }
    
    /// Throws if the garment has no photos.
    func validateHasAtLeastOnePhoto(_ garment: Garment) throws {
        if garment.photoSet.isEmpty {
            throw ValidationError(message: "At least one photo is required")
        }
    }

    // MARK: - Private
    @discardableResult
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


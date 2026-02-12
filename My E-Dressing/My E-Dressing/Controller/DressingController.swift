//
//  DressingController.swift
//  My E-Dressing
//

import CoreData

/// Handles CRUD operations for `Dressing` entities.
final class DressingController {

    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    // MARK: - Create

    /// Creates and saves a new dressing.
    @discardableResult
    func create(name: String, iconName: String = "cabinet.fill", colorHex: String = "D96C45") throws -> Dressing {
        let validatedName = try Validation.nonEmpty(name, fieldName: String(localized: "name"))
        let dressingObject = Dressing(context: managedObjectContext)
        dressingObject.id = UUID()
        dressingObject.name = validatedName
        dressingObject.iconName = iconName
        dressingObject.colorHex = colorHex
        dressingObject.createdAt = Date()
        try managedObjectContext.save()
        return dressingObject
    }

    // MARK: - Fetch or Create Default

    /// Returns the first existing dressing, or creates a default one if none exists.
    func fetchOrCreateDefault() throws -> Dressing {
        if let existing = try first() { return existing }
        return try create(name: String(localized: "default_dressing_name"))
    }

    // MARK: - Read

    /// Fetches all dressings sorted by date.
    func fetchAll() throws -> [Dressing] {
        let request: NSFetchRequest<Dressing> = Dressing.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Dressing.createdAt, ascending: true)]
        return try managedObjectContext.fetch(request)
    }

    /// Returns the first dressing, or nil.
    func first() throws -> Dressing? {
        let request: NSFetchRequest<Dressing> = Dressing.fetchRequest()
        request.fetchLimit = 1
        return try managedObjectContext.fetch(request).first
    }

    /// Finds a dressing by UUID.
    func find(by identifier: UUID) throws -> Dressing? {
        let request: NSFetchRequest<Dressing> = Dressing.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", identifier as CVarArg)
        request.fetchLimit = 1
        return try managedObjectContext.fetch(request).first
    }

    // MARK: - Update

    /// Renames a dressing.
    func rename(_ dressing: Dressing, to newName: String) throws {
        dressing.name = try Validation.nonEmpty(newName, fieldName: String(localized: "name"))
        try managedObjectContext.save()
    }

    /// Updates name, icon and color.
    func update(_ dressing: Dressing, name: String, iconName: String, colorHex: String) throws {
        dressing.name = try Validation.nonEmpty(name, fieldName: String(localized: "name"))
        dressing.iconName = iconName
        dressing.colorHex = colorHex
        try managedObjectContext.save()
    }

    // MARK: - Delete

    /// Cascade-deletes related garments per the data model.
    func delete(_ dressing: Dressing) throws {
        managedObjectContext.delete(dressing)
        try managedObjectContext.save()
    }
}

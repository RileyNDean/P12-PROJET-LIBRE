//
//  DressingController.swift
//  My E-Dressing
//

import CoreData

/// Coordinates CRUD operations for `Dressing` entities.
///
/// This controller is UI-agnostic and operates on a provided `NSManagedObjectContext`.
/// Use a main-thread context when called from UI, or a background context for batch work.
final class DressingController {

    /// The Core Data context used for reading and writing `Dressing` objects.
    private let managedObjectContext: NSManagedObjectContext

    /// Creates a controller bound to a given Core Data context.
    /// - Parameter managedObjectContext: A main or background `NSManagedObjectContext`.
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    // MARK: - Create

    /// Creates and persists a new `Dressing`.
    /// - Parameter name: Non-empty name for the dressing.
    /// - Returns: The newly created and saved `Dressing` instance.
    /// - Throws: `ValidationError` if the name is empty, or any Core Data save error.
    @discardableResult
    func create(name: String) throws -> Dressing {
        let validatedName = try Validation.nonEmpty(name, fieldName: "Name")
        let dressingObject = Dressing(context: managedObjectContext)
        dressingObject.id = UUID()
        dressingObject.name = validatedName
        dressingObject.createdAt = Date()
        try managedObjectContext.save()
        return dressingObject
    }

    // MARK: - Read (helpers)

    /// Fetches all `Dressing` objects sorted by creation date.
    /// - Returns: A chronologically ascending array of `Dressing`.
    /// - Throws: Any Core Data fetch error.
    func fetchAll() throws -> [Dressing] {
        let request: NSFetchRequest<Dressing> = Dressing.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Dressing.createdAt, ascending: true)]
        return try managedObjectContext.fetch(request)
    }

    /// Returns the first available `Dressing`, if any.
    /// - Returns: The first `Dressing` or `nil` if none exist.
    /// - Throws: Any Core Data fetch error.
    func first() throws -> Dressing? {
        let request: NSFetchRequest<Dressing> = Dressing.fetchRequest()
        request.fetchLimit = 1
        return try managedObjectContext.fetch(request).first
    }

    /// Finds a `Dressing` by its unique identifier.
    /// - Parameter identifier: The `UUID` of the requested dressing.
    /// - Returns: The matching `Dressing` or `nil` if not found.
    /// - Throws: Any Core Data fetch error.
    func find(by identifier: UUID) throws -> Dressing? {
        let request: NSFetchRequest<Dressing> = Dressing.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", identifier as CVarArg)
        request.fetchLimit = 1
        return try managedObjectContext.fetch(request).first
    }

    // MARK: - Update

    /// Renames an existing dressing and persists the change.
    /// - Parameters:
    ///   - dressing: The `Dressing` to rename.
    ///   - newName: The new non-empty name.
    /// - Throws: `ValidationError` if the name is empty, or any Core Data save error.
    func rename(_ dressing: Dressing, to newName: String) throws {
        dressing.name = try Validation.nonEmpty(newName, fieldName: "Name")
        try managedObjectContext.save()
    }

    // MARK: - Delete

    /// Deletes a dressing. Related garments are cascade-deleted per the data model.
    /// - Parameter dressing: The `Dressing` to remove.
    /// - Throws: Any Core Data save error.
    func delete(_ dressing: Dressing) throws {
        managedObjectContext.delete(dressing)
        try managedObjectContext.save()
    }
}


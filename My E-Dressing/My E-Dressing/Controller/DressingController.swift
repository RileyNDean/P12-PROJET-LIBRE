//
//  DressingController.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import CoreData

/// Coordinates all CRUD operations for `Dressing`.
/// No UI. Works only with an injected NSManagedObjectContext.
final class DressingController {

    private let managedObjectContext: NSManagedObjectContext

    /// - Parameter managedObjectContext: context bound to the UI (main) or a background context.
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    // MARK: - Create

    /// Creates a new `Dressing`.
    /// - Parameter name: non-empty name.
    /// - Returns: the persisted `Dressing`.
    @discardableResult
    func create(name: String) throws -> Dressing {
        let validatedName = try Validation.nonEmpty(name, field: "Name")
        let dressingObject = Dressing(context: managedObjectContext)
        dressingObject.id = UUID()
        dressingObject.name = validatedName
        dressingObject.createdAt = Date()
        try managedObjectContext.save()
        return dressingObject
    }

    // MARK: - Read (helpers)

    /// Fetches all dressings sorted by creation date.
    func fetchAll() throws -> [Dressing] {
        let request: NSFetchRequest<Dressing> = Dressing.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Dressing.createdAt, ascending: true)]
        return try managedObjectContext.fetch(request)
    }

    /// Returns the first dressing if any.
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

    /// Renames an existing dressing.
    func rename(_ dressing: Dressing, to newName: String) throws {
        dressing.name = try Validation.nonEmpty(newName, field: "Name")
        try managedObjectContext.save()
    }

    // MARK: - Delete

    /// Deletes a dressing. Its garments are cascade-deleted per model rule.
    func delete(_ dressing: Dressing) throws {
        managedObjectContext.delete(dressing)
        try managedObjectContext.save()
    }
}

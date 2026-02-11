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

    @discardableResult
    func create(name: String) throws -> Dressing {
        let validatedName = try Validation.nonEmpty(name, fieldName: String(localized: "name"))
        let dressingObject = Dressing(context: managedObjectContext)
        dressingObject.id = UUID()
        dressingObject.name = validatedName
        dressingObject.createdAt = Date()
        try managedObjectContext.save()
        return dressingObject
    }

    // MARK: - Read

    func fetchAll() throws -> [Dressing] {
        let request: NSFetchRequest<Dressing> = Dressing.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Dressing.createdAt, ascending: true)]
        return try managedObjectContext.fetch(request)
    }

    func first() throws -> Dressing? {
        let request: NSFetchRequest<Dressing> = Dressing.fetchRequest()
        request.fetchLimit = 1
        return try managedObjectContext.fetch(request).first
    }

    func find(by identifier: UUID) throws -> Dressing? {
        let request: NSFetchRequest<Dressing> = Dressing.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", identifier as CVarArg)
        request.fetchLimit = 1
        return try managedObjectContext.fetch(request).first
    }

    // MARK: - Update

    func rename(_ dressing: Dressing, to newName: String) throws {
        dressing.name = try Validation.nonEmpty(newName, fieldName: String(localized: "name"))
        try managedObjectContext.save()
    }

    // MARK: - Delete

    /// Cascade-deletes related garments per the data model.
    func delete(_ dressing: Dressing) throws {
        managedObjectContext.delete(dressing)
        try managedObjectContext.save()
    }
}

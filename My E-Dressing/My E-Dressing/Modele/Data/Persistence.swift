// Core Data stack used by the application and previews.
import CoreData

/// Central Core Data stack used by the app.
/// Provides a shared persistent container and a preview in-memory variant.
struct PersistenceController {
    /// Global shared instance for production/runtime usage.
    static let shared = PersistenceController()

    /// In-memory stack for SwiftUI previews and tests.
    /// No data is written to disk; the store lives only for the process lifetime.
    @MainActor
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // Optional seed data for previews: create a sample dressing
        // so the UI has something to render in previews.
        let sample = Dressing(context: viewContext)
        sample.id = UUID()
        sample.name = "My Dressing"
        sample.createdAt = Date()

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return controller
    }()

    /// Underlying NSPersistentContainer holding the SQLite store and contexts.
    let container: NSPersistentContainer

    /// Builds the Core Data stack.
    /// - Parameter inMemory: When true, stores everything in RAM ("/dev/null"), useful for previews/tests.
    init(inMemory: Bool = false) {
        // Must exactly match the .xcdatamodeld name
        container = NSPersistentContainer(name: "My_E_Dressing")

        if inMemory {
            // Redirect the first store to /dev/null to avoid any disk writes.
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        // Load or create the persistent stores (e.g., SQLite files).
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // Fail fast in development so issues are visible.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        // Merge child/background changes into the viewContext automatically.
        container.viewContext.automaticallyMergesChangesFromParent = true

        // Prefer local changes when merging conflicts.
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

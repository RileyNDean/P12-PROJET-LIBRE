//
//  ContentView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import SwiftUI
import CoreData

/// Root view displaying the list of `Dressing` objects from Core Data.
/// In MVC terms, this view is the "View" layer: it renders UI and forwards
/// user intents (add/delete) to the model via the managed object context.

/// The main list screen for dressings.
struct ContentView: View {
    /// Core Data managed object context injected via the environment.
    @Environment(\.managedObjectContext) private var viewContext

    /// Live fetch request providing the current list of `Dressing` objects.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Dressing.createdAt, ascending: true)],
        animation: .default)
    private var dressings: FetchedResults<Dressing>

    var body: some View {
        NavigationView {
            List {
                ForEach(dressings) { dressing in
                    NavigationLink {
                        Text("Created at \((dressing.createdAt ?? Date()), formatter: dateFormatter)")
                    } label: {
                        HStack {
                            Text(dressing.name ?? "Unnamed dressing")
                            Spacer()
                            Text((dressing.createdAt ?? Date()), formatter: dateFormatter)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteDressings)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addDressing) {
                        Label("Add Dressing", systemImage: "plus")
                    }
                }
            }
            Text("Sélectionnez un dressing")
        }
    }

    /// Creates a new `Dressing` with default values and saves it to Core Data.
    private func addDressing() {
        withAnimation {
            let newDressing = Dressing(context: viewContext)
            newDressing.id = UUID()
            newDressing.name = "Nouveau dressing"
            newDressing.createdAt = Date()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    /// Deletes selected `Dressing` objects and persists the change.
    private func deleteDressings(offsets: IndexSet) {
        withAnimation {
            offsets.map { dressings[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

/// Shared date formatter for displaying creation dates.
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

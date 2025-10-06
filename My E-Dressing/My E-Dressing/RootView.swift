//
// RootView.swift
//
// The main navigation hub of the MEDressing app, providing access to dressings and the ability to add new clothing items.
// This view does not directly access the model; it serves as a container and navigation point.
//

import SwiftUI
import CoreData

/// The RootView serves as the main navigation hub of the MEDressing app.
/// It provides navigation to the list of dressings and a button to add new clothing.
/// This view should not access the data model directly, but rather present views that do.
struct RootView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isPresentingAdd = false  // State controlling the presentation of the add clothing sheet

    var body: some View {
        NavigationStack {
            Group {
                // Placeholder: will be replaced with Core Data list of clothing later
                ContentPlaceholder()
            }
            .navigationTitle("MEDressing")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        DressingsListView()
                    } label: {
                        Label("Dressings", systemImage: "folder")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresentingAdd = true   // Trigger sheet presentation
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAdd) {
                // AddClothingView presented modally; inject context here
                AddClothingView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

private struct ContentPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.dress.line.vertical.figure")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Your dressing is empty for now.")
                .foregroundStyle(.secondary)
            Text("Add a clothing item using the “+” button.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    RootView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

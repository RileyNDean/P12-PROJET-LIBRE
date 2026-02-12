//
//  Untitled.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 10/10/2025.
//

import SwiftUI
import CoreData

/// Legacy list view displaying all dressings with navigation and swipe actions.
struct DressingListView: View {
    
    @State private var editingDressing: Dressing? = nil
    @State private var deleteDressing: Dressing? = nil
    
    @Environment(\.managedObjectContext) private var context

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Dressing.createdAt, ascending: true)],
        animation: .default
    ) private var dressings: FetchedResults<Dressing>

    @State private var showNewDressing = false
    @State private var navigateToDressing: Dressing? = nil

    var body: some View {
        Group {
            if dressings.isEmpty {
                VStack(spacing: 12) {
                    Text(String(localized: "no_dressings_yet"))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(dressings) { dressing in
                        NavigationLink {
                            GarmentListView(dressing: dressing)
                        } label: {
                            HStack {
                                Text(dressing.name ?? String(localized: "unnamed_dressing"))
                                Spacer()
                                Text("\(dressing.garments?.count ?? 0)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .swipeActions(allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteDressing = dressing
                            } label: {
                                Label(String(localized: "delete"), systemImage: "trash")
                            }
                            Button {
                                editingDressing = dressing
                            } label: {
                                Label(String(localized: "edit"), systemImage: "pencil")
                            }
                        }
                    }
                    .onDelete { idx in
                        let items = idx.map { dressings[$0] }
                        items.forEach { context.delete($0) }
                        try? context.save()
                    }
                }
            }
        }
        .navigationTitle(String(localized: "dressings_title"))
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(item: $navigateToDressing) { dressing in
            GarmentListView(dressing: dressing)
        }
        .sheet(isPresented: $showNewDressing) {
            DressingFormView { newDressing in
                navigateToDressing = newDressing
            }
        }
        .sheet(item: $editingDressing) { dressing in
            DressingFormView(editingDressing: dressing, onSaved: {_ in} )
        }
        .alert(
            String(localized: "confirm_delete_dressing_title"),
            isPresented: .constant(deleteDressing != nil),
            presenting: deleteDressing,
        ) { dressing in
            Button(String(localized: "delete"), role: .destructive) {
                performDelete(dressing)
                deleteDressing = nil
            }
            Button(String(localized: "cancel"), role: .cancel) {
                deleteDressing = nil
            }
        } message: { dressing in
            Text("\(dressing.name ?? String(localized: "unnamed_dressing")) — \(String(format: String(localized: "garments_count"), dressing.garments?.count ?? 0))")
        }
        .floatingButtonCentered(
            title: String(localized: "new_dressing"),
            systemImage: "plus"
        ) { showNewDressing = true }
    }
    
    /// Permanently deletes the given dressing from Core Data.
    private func performDelete(_ dressing: Dressing) {
        context.delete(dressing)
        do { try context.save() } catch {
        }
    }
}


//
//  Untitled.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 10/10/2025.
//

import SwiftUI
import CoreData

struct DressingListView: View {
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
                    Text("Vous n'avez pas encore de dressing")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(dressings) { dressing in
                        NavigationLink(value: dressing) {
                            HStack {
                                Text(dressing.name ?? String(localized: "unnamed"))
                                Spacer()
                                Text("\(dressing.garments?.count ?? 0)")
                                    .foregroundStyle(.secondary)
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
        .navigationDestination(for: Dressing.self) { dressing in
            GarmentListView(dressing: dressing)
        }
        .sheet(isPresented: $showNewDressing) {
            DressingFormView { newDressing in
                navigateToDressing = newDressing
            }
        }
        .floatingButtonCentered(
            title: String(localized: "new_dressing"),
            systemImage: "plus"
        ) { showNewDressing = true }
    }
}

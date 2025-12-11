//
//  Untitled.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 10/10/2025.
//

import SwiftUI
import CoreData

struct DressingListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isCreating = false

    @FetchRequest(
        sortDescriptors: [],
        animation: .default
    )
    private var dressings: FetchedResults<Dressing>

    @State private var showNewDressing = false
    @State private var editingDressing: Dressing? = nil

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mes dressings")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)

                        Text("Gère tes dressings par saison, style ou pièce.")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.top, AppTheme.paddingLarge)
                    .padding(.horizontal, AppTheme.paddingMedium)

                    if dressings.isEmpty {
                        EmptyDressingsView {
                            showNewDressing = true
                        }
                        .padding(.horizontal, AppTheme.paddingMedium)
                        .padding(.top, 8)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(dressings) { dressing in
                                NavigationLink {
                                   // DressingDetailView(dressing: dressing)   // ton écran détail existant
                                } label: {
                                    DressingCardView(
                                        name: dressing.name ?? "Sans nom",
                                        itemCount: (dressing.garments as? Set<Garment>)?.count ?? 0,
                                        icon: dressing.icon
                                    )
                                }
                                .buttonStyle(.plain)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        delete(dressing)
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }

                                    Button {
                                        editingDressing = dressing
                                        showNewDressing = true
                                    } label: {
                                        Label("Modifier", systemImage: "pencil")
                                    }
                                    .tint(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.paddingMedium)
                        .padding(.top, 4)
                        .padding(.bottom, 80)
                    }
                }
            }
            .background(AppTheme.background.ignoresSafeArea())

            FloatingActionButton(
                icon: "plus",
                label: "Nouveau dressing"
            ) {
                editingDressing = nil
                showNewDressing = true
            }
            .padding(.trailing, AppTheme.paddingMedium)
            .padding(.bottom, AppTheme.paddingLarge)
        }
        .sheet(isPresented: $showNewDressing) {
            DressingFormView(editingDressing: editingDressing) { newDressing in
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(32)                
        }

    }

    private func delete(_ dressing: Dressing) {
        viewContext.delete(dressing)
        try? viewContext.save()
    }
}

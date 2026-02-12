//
//  ModernGarmentListView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 12/12/2025.
//

import SwiftUI
import CoreData

/// Scrollable list of garments belonging to a specific dressing.
struct ModernGarmentListView: View {
    @ObservedObject var dressing: Dressing
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var expandedGarmentId: UUID? = nil

    @State private var showAddForm = false
    @State private var editingGarment: Garment?
    
    @FetchRequest var garments: FetchedResults<Garment>
    
    init(dressing: Dressing) {
        self.dressing = dressing
        self._garments = FetchRequest(
            entity: Garment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Garment.createdAt, ascending: false)],
            predicate: NSPredicate(format: "dressing == %@", dressing)
        )
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.themeBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 12) {
                    Color.clear.frame(height: 10)
                    
                    if garments.isEmpty {
                        EmptyStateView()
                    } else {
                        ForEach(garments) { garment in
                            ModernGarmentRow(
                                garment: garment,
                                expandedGarmentId: $expandedGarmentId,
                                onEdit: { editingGarment = garment }
                            )
                        }
                    }
                    
                    Color.clear.frame(height: 100)
                }
            }
            
            Button { showAddForm = true } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themePrimary)
                    .frame(width: 56, height: 56)
                    .background(Color.themeSecondary)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 100)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(dressing.name ?? String(localized: "dressing"))
                    .font(.serifTitle3)
                    .foregroundStyle(Color.themeSecondary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(String(localized: "sort_by_date"), action: {})
                    Button(String(localized: "sort_by_brand"), action: {})
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundStyle(Color.themeSecondary)
                }
            }
        }
        .sheet(isPresented: $showAddForm) {
            GarmentFormView(selectedDressing: dressing)
        }
        .sheet(item: $editingGarment) { garment in
            GarmentFormView(editingGarment: garment, selectedDressing: dressing)
        }
    }
}

/// Placeholder shown when the dressing contains no garments.
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hanger")
                .font(.system(size: 60))
                .foregroundStyle(Color.themeSecondary.opacity(0.2))
            Text(String(localized: "empty_dressing_title"))
                .font(.serifTitle3)
                .foregroundStyle(Color.themeSecondary)
            Text(String(localized: "empty_dressing_subtitle"))
                .font(.sansCaption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 100)
    }
}


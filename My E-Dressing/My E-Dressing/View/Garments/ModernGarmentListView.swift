//
//  ModernGarmentListView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 12/12/2025.
//

import SwiftUI
import CoreData

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
                HStack {
                    Image(systemName: "tshirt")
                    Text("Add")
                }
                .padding()
                .background(Color.themeSecondary)
                .foregroundColor(.white)
                .cornerRadius(30)
                .shadow(radius: 5)
            }
            .padding()
        }
        .navigationTitle(dressing.name ?? "Dressing")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Sort by date", action: {})
                    Button("Sort by brand", action: {})
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

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hanger")
                .font(.system(size: 60))
                .foregroundStyle(Color.themeSecondary.opacity(0.2))
            Text("This dressing is empty")
                .font(.title3)
                .foregroundStyle(Color.themeSecondary)
            Text("Add your first garment by tapping the + button")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 100)
    }
}


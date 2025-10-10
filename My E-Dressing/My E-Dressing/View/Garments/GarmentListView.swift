//
//  GarmentListView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 10/10/2025.
//

import SwiftUI
import CoreData
import UIKit

struct GarmentListView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @ObservedObject var dressing: Dressing

    @State private var isPresentingNewGarmentForm = false
    @State private var editingGarment: Garment? = nil
    @State private var garmentPendingDeletion: Garment? = nil
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @State private var isRenamingDressing = false

    private var fetchRequest: FetchRequest<Garment>
    private var fetchedGarments: FetchedResults<Garment> { fetchRequest.wrappedValue }

    init(dressing: Dressing) {
        self.dressing = dressing
        self.fetchRequest = FetchRequest<Garment>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Garment.createdAt, ascending: false)],
            predicate: NSPredicate(format: "dressing == %@", dressing)
        )
    }

    var body: some View {
        
        List {
            if fetchedGarments.isEmpty {
                Text(String(localized: "no_garments_yet"))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(fetchedGarments) { garment in
                    GarmentCardView(garment: garment) { editingGarment = garment }
                        .listRowInsets(EdgeInsets())
                        .swipeActions(allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                garmentPendingDeletion = garment
                            } label: {
                                Label(String(localized: "delete"), systemImage: "trash")
                            }
                            Button {
                                editingGarment = garment
                            } label: {
                                Label(String(localized: "edit"), systemImage: "square.and.pencil")
                            }
                        }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isRenamingDressing = true
                } label: {
                    Label(String(localized: "edit"), systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $isRenamingDressing) {
            DressingFormView(editingDressing: dressing)
        }
        .listStyle(.plain)
        .navigationTitle(dressing.name ?? String(localized: "dressing"))
        .floatingButtonCentered(
            title: String(localized: "add_title"),
            systemImage: "plus"
        ) { isPresentingNewGarmentForm = true }
        .sheet(isPresented: $isPresentingNewGarmentForm) {
            GarmentFormView(editingGarment: nil, selectedDressing: dressing)
        }
        .sheet(item: $editingGarment) { garment in
            GarmentFormView(editingGarment: garment, selectedDressing: dressing)
        }
        .alert(
            String(localized: "delete"),
            isPresented: Binding(get: { garmentPendingDeletion != nil }, set: { _ in })
        ) {
            Button(String(localized: "cancel"), role: .cancel) { garmentPendingDeletion = nil }
            Button(String(localized: "delete"), role: .destructive) {
                if let g = garmentPendingDeletion { deleteGarments([g]) }
                garmentPendingDeletion = nil
            }
        } message: {
            Text(String(localized: "confirm_delete_item"))
        }
        .alert(String(localized: "error_title"), isPresented: $isShowingAlert) {
            Button(String(localized: "ok"), role: .cancel) {}
        } message: { Text(alertMessage) }
        
    }

    // Actions
    private func changeStatus(_ garment: Garment, to newStatus: GarmentStatus) {
        do { try GarmentController(managedObjectContext: managedObjectContext).changeStatus(garment, to: newStatus) }
        catch { alertMessage = String(localized: "unexpected_error"); isShowingAlert = true }
    }
    private func incrementWearCount(_ garment: Garment) {
        do { try GarmentController(managedObjectContext: managedObjectContext).incrementWearCount(garment) }
        catch { alertMessage = String(localized: "unexpected_error"); isShowingAlert = true }
    }
    private func deleteGarments(_ garments: [Garment]) {
        do {
            let controller = GarmentController(managedObjectContext: managedObjectContext)
            try garments.forEach { try controller.delete($0) }
        } catch {
            alertMessage = String(localized: "unexpected_error")
            isShowingAlert = true
        }
    }
}



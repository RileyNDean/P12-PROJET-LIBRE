//
//  GarmentListView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 10/10/2025.
//

import SwiftUI
import CoreData
import UIKit

/// Lists garments for a given dressing. Allows add, edit, status change, and delete.
struct GarmentListView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @ObservedObject var dressing: Dressing

    @State private var isPresentingNewGarmentForm: Bool = false
    @State private var editingGarment: Garment? = nil
    @State private var isShowingAlert: Bool = false
    @State private var alertMessage: String = ""

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
            ForEach(fetchedGarments) { garment in
                Button {
                    editingGarment = garment
                } label: {
                    HStack(spacing: 12) {
                        thumbnailView(for: garment)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(garment.title ?? "")
                                .font(.headline)
                            Text(GarmentStatus(rawValue: garment.statusRaw)?.label ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if let wearCount = garment.value(forKey: "wearCount") as? Int32, wearCount > 0 {
                            Text("×\(wearCount)")
                                .font(.caption)
                                .padding(6)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(8)
                        }
                    }
                }
                .contextMenu {
                    Button(String(localized: "mark_worn")) { incrementWear(garment) }
                    Menu(String(localized: "change_status")) {
                        ForEach(GarmentStatus.allCases) { status in
                            Button(status.label) { changeStatus(garment, to: status) }
                        }
                    }
                    Button(role: .destructive) { deleteGarments([garment]) } label: {
                        Text(String(localized: "delete"))
                    }
                }
            }
            .onDelete { indexSet in
                let toDelete = indexSet.map { fetchedGarments[$0] }
                deleteGarments(toDelete)
            }
        }
        .navigationTitle(dressing.name ?? String(localized: "dressing"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { isPresentingNewGarmentForm = true }
                label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $isPresentingNewGarmentForm) {
            GarmentFormView(editingGarment: nil, selectedDressing: dressing)
        }
        .sheet(item: $editingGarment) { garment in
            GarmentFormView(editingGarment: garment, selectedDressing: dressing)
        }
        .alert(String(localized: "error_title"), isPresented: $isShowingAlert) {
            Button(String(localized: "ok"), role: .cancel) {}
        } message: { Text(alertMessage) }
    }

    // MARK: Row helpers

    private func thumbnailView(for garment: Garment) -> some View {
        let image: UIImage? = {
            if let path = garment.primaryPhotoPath {
                return MediaStore.shared.loadImage(at: path)
            }
            return nil
        }()
        return Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Image(systemName: "photo")
                    .frame(width: 56, height: 56)
            }
        }
    }

    // MARK: Actions

    private func changeStatus(_ garment: Garment, to newStatus: GarmentStatus) {
        do { try GarmentController(managedObjectContext: managedObjectContext).changeStatus(garment, to: newStatus) }
        catch { alertMessage = String(localized: "unexpected_error"); isShowingAlert = true }
    }

    private func incrementWear(_ garment: Garment) {
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

//
//  GarmentFormView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

// Form to create or edit a garment with multiple photos.

import SwiftUI
import CoreData
import UIKit

/// UI to create or edit a garment with multiple photos.
/// This view delegates persistence to `GarmentController`.
struct GarmentFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var managedObjectContext

    // When not nil → edit mode; when nil → create mode.
    var editingGarment: Garment? = nil
    var selectedDressing: Dressing? = nil

    // Text fields
    @State private var titleText: String = ""
    @State private var brandText: String = ""
    @State private var colorText: String = ""
    @State private var sizeText: String = ""
    @State private var categoryText: String = ""
    @State private var notesText: String = ""
    @State private var wearCount: Int32 = 0
    @State private var statusValue: GarmentStatus = .kept

    // Photos working set (acts as the view-model layer for images)
    @State private var workingPhotoItems: [PhotoItem] = []
    @State private var isShowingPicker: Bool = false
    @State private var pickerSelectedImages: [UIImage] = []

    // UI state
    @State private var isSaving: Bool = false
    @State private var isShowingAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Photos
                Section(String(localized: "photos_title")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Button { isShowingPicker = true } label: {
                                VStack {
                                    Image(systemName: "plus.circle").font(.largeTitle)
                                    Text(String(localized: "add_title"))
                                }
                                .frame(width: 96, height: 96)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(12)
                            }

                            ForEach(Array(workingPhotoItems.enumerated()), id: \.element.id) { index, photoItem in
                                let thumbnail: UIImage = {
                                    switch photoItem {
                                    case .existing(_, let existingThumbnail): return existingThumbnail
                                    case .new(let newImage): return newImage
                                    }
                                }()

                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: thumbnail)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 96, height: 96)
                                        .clipped()
                                        .cornerRadius(12)

                                    Button {
                                        workingPhotoItems.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                                    }
                                    .offset(x: 6, y: -6)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    Text(shouldShowPhotoRequirementHint ? String(localized: "photo_required") : "")
                        .foregroundStyle(.secondary)
                }

                // MARK: - Information
                Section(String(localized: "information_title")) {
                    TextField(String(localized: "title_required_placeholder"), text: $titleText)
                    TextField(String(localized: "brand_placeholder"), text: $brandText)
                    TextField(String(localized: "color_placeholder"), text: $colorText)
                    TextField(String(localized: "size_placeholder"), text: $sizeText)
                    TextField(String(localized: "category_placeholder"), text: $categoryText)

                    Picker(String(localized: "status_title"), selection: $statusValue) {
                        ForEach(GarmentStatus.allCases) { status in
                            Text(status.label).tag(status)
                        }
                    }
                    Stepper(
                        String(localized: "wearcount_title") + " \(wearCount)",
                        value: $wearCount,
                        in: 0...999
                    )
                    .accessibilityIdentifier("wearCountStepper")


                    TextField(String(localized: "notes_placeholder"), text: $notesText, axis: .vertical)
                }
            }
            .navigationTitle(editingGarment == nil ? String(localized: "new_garment") : String(localized: "edit_garment"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "save")) { save() }.disabled(!canSave)
                }
            }
            .sheet(isPresented: $isShowingPicker) {
                ImagePickerMulti(images: $pickerSelectedImages)
            }
            .onChange(of: pickerSelectedImages) { _, selectedImages in
                let newItems = selectedImages.map { PhotoItem.new(image: $0) }
                workingPhotoItems.append(contentsOf: newItems)
                pickerSelectedImages.removeAll()
            }
            .onAppear(perform: loadIfEditing)
            .alert(String(localized: "error_title"), isPresented: $isShowingAlert) {
                Button(String(localized: "ok"), role: .cancel) {}
            } message: { Text(alertMessage) }
            .overlay {
                if isSaving {
                    ZStack {
                        Color.black.opacity(0.2).ignoresSafeArea()
                        ProgressView("Saving...")
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(12)
                    }
                }
            }
        }
    }

    // MARK: - Derived UI state

    /// Live validation for the Save button.
    private var canSave: Bool {
        let hasTitle = !titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasAtLeastOnePhoto = editingGarment != nil ? true : !workingPhotoItems.isEmpty
        return hasTitle && hasAtLeastOnePhoto
    }

    private var shouldShowPhotoRequirementHint: Bool {
        editingGarment == nil && workingPhotoItems.isEmpty
    }

    // MARK: - Lifecycle

    /// Pre-fills fields and thumbnails when editing an existing garment.
    private func loadIfEditing() {
        guard let garment = editingGarment else { return }
        titleText = garment.title ?? ""
        brandText = garment.brand ?? ""
        colorText = garment.color ?? ""
        sizeText = garment.size ?? ""
        categoryText = garment.category ?? ""
        notesText = garment.notes ?? ""
        wearCount = garment.wearCount
        statusValue = GarmentStatus(rawValue: garment.statusRaw) ?? .kept

        workingPhotoItems = garment.orderedPhotos.compactMap { garmentPhoto in
            guard
                let absolutePath = garmentPhoto.path,
                let thumbnailImage = MediaStore.shared.loadImage(at: absolutePath)
            else { return nil }
            return .existing(photoObject: garmentPhoto, thumbnail: thumbnailImage)
        }
    }

    // MARK: - Actions

    /// Saves changes by applying a diff: keep, add, remove. Enforces business rules in the controller.
    private func save() {
        isSaving = true
        defer { isSaving = false }

        do {
            let controller = GarmentController(managedObjectContext: managedObjectContext)

            if let garment = editingGarment {
                try controller.update(
                    garment,
                    title: titleText,
                    brand: brandText,
                    color: colorText,
                    size: sizeText,
                    category: categoryText,
                    notes: notesText,
                    wearCount: wearCount,
                    status: statusValue
                )

                let keptExistingPhotoObjects: [GarmentPhoto] = workingPhotoItems.compactMap {
                    if case let .existing(photoObject, _) = $0 { return photoObject } else { return nil }
                }
                let currentExistingPhotoObjects = Array(garment.photoSet)
                let photoObjectsToRemove = currentExistingPhotoObjects.filter { !keptExistingPhotoObjects.contains($0) }
                if !photoObjectsToRemove.isEmpty {
                    try controller.removePhotos(photoObjectsToRemove, from: garment)
                }

                let imagesToAdd: [UIImage] = workingPhotoItems.compactMap {
                    if case let .new(newImage) = $0 { return newImage } else { return nil }
                }
                if !imagesToAdd.isEmpty {
                    _ = try controller.addPhotos(imagesToAdd, to: garment)
                }

                let orderedForController: [GarmentPhoto] = workingPhotoItems.compactMap {
                    if case let .existing(photoObject, _) = $0 { return photoObject } else { return nil }
                }
                if !orderedForController.isEmpty {
                    try controller.reorderPhotos(orderedForController)
                }

                try controller.validateHasAtLeastOnePhoto(garment)

            } else {
                let dressing = try selectedDressing ?? fetchOrCreateDefaultDressing()
                let photosForCreation: [UIImage] = workingPhotoItems.compactMap {
                    if case let .new(newImage) = $0 { return newImage } else { return nil }
                }
                _ = try controller.create(
                    in: dressing,
                    title: titleText,
                    brand: brandText,
                    color: colorText,
                    size: sizeText,
                    category: categoryText,
                    notes: notesText,
                    status: statusValue,
                    wearCount: wearCount,
                    photos: photosForCreation
                )
            }

            dismiss()

        } catch let error as ValidationError {
            alertMessage = error.message
            isShowingAlert = true
        } catch {
            alertMessage = String(localized: "unexpected_error")
            isShowingAlert = true
        }
    }

    /// Returns an existing dressing or creates a default one to allow quick testing.
    /// - Throws: Any Core Data fetch/save error.
    private func fetchOrCreateDefaultDressing() throws -> Dressing {
        let request: NSFetchRequest<Dressing> = Dressing.fetchRequest()
        request.fetchLimit = 1
        if let first = try managedObjectContext.fetch(request).first { return first }
        return try DressingController(managedObjectContext: managedObjectContext).create(name: String(localized: "default_dressing_name"))
    }
}


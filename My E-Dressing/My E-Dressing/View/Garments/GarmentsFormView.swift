//
//  GarmentFormView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import SwiftUI
import CoreData
import UIKit

/// Form for creating or editing a garment (photos, metadata, category, size, status).
struct GarmentFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var managedObjectContext

    var editingGarment: Garment? = nil
    var selectedDressing: Dressing? = nil

    @State private var titleText: String = ""
    @State private var brandText: String = ""
    @State private var colorText: String = ""
    @State private var sizeText: String = ""
    @State private var categoryText: String = ""
    @State private var notesText: String = ""
    @State private var wearCount: Int32 = 0
    @State private var statusValue: GarmentStatus = .kept

    @State private var workingPhotoItems: [PhotoItem] = []
    @State private var isShowingPicker: Bool = false
    @State private var pickerSelectedImages: [UIImage] = []

    @State private var isSaving: Bool = false
    @State private var isShowingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isShowingCategoryPicker: Bool = false
    @State private var isShowingSizePicker: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        // MARK: - Header
                        VStack(spacing: 6) {
                            Image(systemName: "tshirt.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(Color.themePrimary)
                                .frame(width: 60, height: 60)
                                .background(Color.themePrimary.opacity(0.15))
                                .clipShape(Circle())

                            Text(editingGarment == nil ? String(localized: "new_garment") : String(localized: "edit_garment"))
                                .font(.serifTitle)
                                .foregroundStyle(Color.themeSecondary)
                        }

                        // MARK: - Photos
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "photos_title"))
                                .font(.sansCaption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.themeSecondary)
                                .padding(.leading, 4)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    Button { isShowingPicker = true } label: {
                                        VStack(spacing: 6) {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 22))
                                                .foregroundStyle(Color.themePrimary)
                                            Text(String(localized: "add_title"))
                                                .font(.sansCaption)
                                                .foregroundStyle(Color.themePrimary)
                                        }
                                        .frame(width: 80, height: 100)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.themePrimary.opacity(0.3),
                                                        style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                        )
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
                                                .frame(width: 80, height: 100)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))

                                            Button {
                                                workingPhotoItems.remove(at: index)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 18))
                                                    .foregroundStyle(.white)
                                                    .background(Circle().fill(Color.red).frame(width: 20, height: 20))
                                            }
                                            .offset(x: 6, y: -6)
                                        }
                                    }
                                }
                            }

                            if shouldShowPhotoRequirementHint {
                                Text(String(localized: "photo_required"))
                                    .font(.sansCaption)
                                    .foregroundStyle(Color.themePrimary.opacity(0.7))
                                    .padding(.leading, 4)
                            }
                        }

                        // MARK: - Informations
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "information_title"))
                                .font(.sansCaption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.themeSecondary)
                                .padding(.leading, 4)

                            VStack(spacing: 0) {
                                FormTextField(placeholder: String(localized: "title_required_placeholder"), text: $titleText, isRequired: true)
                                FormDivider()
                                FormTextField(placeholder: String(localized: "brand_placeholder"), text: $brandText)
                                FormDivider()
                                FormTextField(placeholder: String(localized: "color_placeholder"), text: $colorText)
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.themeSecondary.opacity(0.08), lineWidth: 1)
                            )
                        }

                        // MARK: - Details
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "details_title"))
                                .font(.sansCaption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.themeSecondary)
                                .padding(.leading, 4)

                            HStack(spacing: 12) {
                                CategoryCardView(
                                    categoryText: $categoryText,
                                    isShowingPicker: $isShowingCategoryPicker
                                )
                                SizeCardView(
                                    sizeText: $sizeText,
                                    isShowingPicker: $isShowingSizePicker
                                )
                            }

                            HStack(spacing: 12) {
                                StatusCardView(statusValue: $statusValue)
                                WearCountCardView(wearCount: $wearCount)
                            }
                        }

                        // MARK: - Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "notes_placeholder"))
                                .font(.sansCaption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.themeSecondary)
                                .padding(.leading, 4)

                            TextField(String(localized: "notes_placeholder"), text: $notesText, axis: .vertical)
                                .font(.sansBody)
                                .lineLimit(3...6)
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.themeSecondary.opacity(0.08), lineWidth: 1)
                                )
                        }

                        // MARK: - Buttons
                        HStack(spacing: 16) {
                            Button {
                                dismiss()
                            } label: {
                                Text(String(localized: "cancel"))
                                    .font(.sansHeadline)
                                    .foregroundStyle(Color.themeSecondary)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(16)
                            }

                            Button {
                                save()
                            } label: {
                                Text(String(localized: "save"))
                                    .font(.sansHeadline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(canSave ? Color.themePrimary : Color.gray.opacity(0.3))
                                    .cornerRadius(16)
                            }
                            .disabled(!canSave)
                        }
                        .padding(.bottom, 16)
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("")
                }
            }
            .sheet(isPresented: $isShowingPicker) {
                ImagePickerMulti(images: $pickerSelectedImages)
            }
            .sheet(isPresented: $isShowingCategoryPicker) {
                CategoryPickerView(selectedCategoryId: categoryOptionalId)
            }
            .sheet(isPresented: $isShowingSizePicker) {
                SizePickerView(selectedSizeId: sizeOptionalId)
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
                        ProgressView(String(localized: "saving"))
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(12)
                    }
                }
            }
        }
    }

    // MARK: - Derived State

    private var categoryOptionalId: Binding<String?> {
        Binding<String?>(
            get: { categoryText.isEmpty ? nil : categoryText },
            set: { categoryText = $0 ?? "" }
        )
    }

    private var sizeOptionalId: Binding<String?> {
        Binding<String?>(
            get: { sizeText.isEmpty ? nil : sizeText },
            set: { sizeText = $0 ?? "" }
        )
    }

    private var canSave: Bool {
        let hasTitle = !titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasAtLeastOnePhoto = editingGarment != nil ? true : !workingPhotoItems.isEmpty
        return hasTitle && hasAtLeastOnePhoto
    }

    private var shouldShowPhotoRequirementHint: Bool {
        editingGarment == nil && workingPhotoItems.isEmpty
    }

    // MARK: - Lifecycle

    /// Loads garment data when editing.
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

        workingPhotoItems = garment.allLoadedImages.compactMap { item in
            guard let photo = garment.orderedPhotos.first(where: { $0.id == item.id }) else { return nil }
            return .existing(photoObject: photo, thumbnail: item.image)
        }
    }

    // MARK: - Actions

    /// Saves the garment and dismisses.
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
                let dressingCtrl = DressingController(managedObjectContext: managedObjectContext)
                let dressing = try selectedDressing ?? dressingCtrl.fetchOrCreateDefault()
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
}

// MARK: - Form Components

/// A single-line text field used inside the form.
private struct FormTextField: View {
    let placeholder: String
    @Binding var text: String
    var isRequired: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            TextField(placeholder, text: $text)
                .font(.sansBody)
                .foregroundStyle(Color.themeSecondary)
            if isRequired && text.isEmpty {
                Text("*")
                    .font(.sansBody)
                    .foregroundStyle(Color.themePrimary)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
    }
}

/// A thin horizontal divider used between form fields.
private struct FormDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.themeSecondary.opacity(0.08))
            .frame(height: 1)
            .padding(.leading, 16)
    }
}

// MARK: - Status Card

/// Shows "+" with "Statut" label. Tap opens a 2x2 grid to pick a status.
/// Once picked, shows the status icon + label. Tap again to change.
struct StatusCardView: View {
    @Binding var statusValue: GarmentStatus
    @State private var showPicker = false
    @State private var hasSelected = false

    var body: some View {
        VStack(spacing: 10) {
            Spacer()

            if showPicker {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(GarmentStatus.allCases) { status in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                statusValue = status
                                hasSelected = true
                                showPicker = false
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: status.icon)
                                    .font(.system(size: 22))
                                    .foregroundStyle(statusValue == status && hasSelected ? Color.themePrimary : Color.themeSecondary)
                                Text(status.label)
                                    .font(.sansCaption2)
                                    .foregroundStyle(Color.themeSecondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(statusValue == status && hasSelected ? Color.themePrimary.opacity(0.12) : Color.clear)
                            .cornerRadius(8)
                        }
                    }
                }
            } else if hasSelected {
                // Status selected — show icon, tappable to change
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        showPicker = true
                    }
                } label: {
                    Image(systemName: statusValue.icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.themePrimary)
                        .frame(width: 50, height: 50)
                        .background(Color.themePrimary.opacity(0.12))
                        .clipShape(Circle())
                }
            } else {
                // Initial state — "+" button
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        showPicker = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.themePrimary)
                        .frame(width: 50, height: 50)
                        .background(Color.themePrimary.opacity(0.12))
                        .clipShape(Circle())
                }
            }

            Spacer()

            Text(hasSelected && !showPicker ? statusValue.label : String(localized: "status_title"))
                .font(.sansCaption)
                .foregroundStyle(Color.themeSecondary)
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.themeSecondary.opacity(0.08), lineWidth: 1)
        )
        .onAppear {
            // If editing an existing garment, mark as already selected
            if statusValue != .kept {
                hasSelected = true
            }
        }
    }
}

// MARK: - Wear Count Card

/// Card with "−" [tappable number] "+", label below. Tap the number for manual keyboard input.
struct WearCountCardView: View {
    @Binding var wearCount: Int32
    @State private var isEditing = false
    @State private var editText = ""
    @FocusState private var textFieldFocused: Bool

    var body: some View {
        VStack(spacing: 10) {
            Spacer()

            HStack(spacing: 16) {
                Button {
                    if wearCount > 0 { wearCount -= 1 }
                    editText = "\(wearCount)"
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(wearCount > 0 ? Color.themePrimary : Color.themeSecondary.opacity(0.2))
                        .frame(width: 36, height: 36)
                        .background(Color.themePrimary.opacity(0.12))
                        .clipShape(Circle())
                }
                .disabled(wearCount <= 0)

                if isEditing {
                    TextField("0", text: $editText)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.themePrimary)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(minWidth: 40, maxWidth: 60)
                        .focused($textFieldFocused)
                        .onSubmit { commitEdit() }
                        .onChange(of: textFieldFocused) { _, focused in
                            if !focused { commitEdit() }
                        }
                } else {
                    Text("\(wearCount)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.themePrimary)
                        .frame(minWidth: 30)
                        .onTapGesture {
                            editText = wearCount == 0 ? "" : "\(wearCount)"
                            isEditing = true
                            textFieldFocused = true
                        }
                }

                Button {
                    if wearCount < 999 { wearCount += 1 }
                    editText = "\(wearCount)"
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.themePrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.themePrimary.opacity(0.12))
                        .clipShape(Circle())
                }
                .disabled(wearCount >= 999)
            }

            Spacer()

            Text(String(localized: "wearcount_title"))
                .font(.sansCaption)
                .foregroundStyle(Color.themeSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.themeSecondary.opacity(0.08), lineWidth: 1)
        )
    }

    /// Validates and applies the manual wear count edit.
    private func commitEdit() {
        isEditing = false
        if let value = Int32(editText), value >= 0, value <= 999 {
            wearCount = value
        }
        editText = "\(wearCount)"
    }
}

// MARK: - Category Card

/// Shows "+" with "Catégorie" label. Tap opens the category picker sheet.
/// Once picked, shows the category icon + label. Tap again to change.
struct CategoryCardView: View {
    @Binding var categoryText: String
    @Binding var isShowingPicker: Bool

    private var selectedCategory: GarmentCategory? {
        GarmentCategoryCatalog.find(by: categoryText)
    }

    var body: some View {
        Button { isShowingPicker = true } label: {
            VStack(spacing: 10) {
                Spacer()

                if let cat = selectedCategory {
                    Image(cat.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.themePrimary)
                        .frame(width: 50, height: 50)
                        .background(Color.themePrimary.opacity(0.12))
                        .clipShape(Circle())
                }

                Spacer()

                Text(selectedCategory?.label ?? String(localized: "category_placeholder"))
                    .font(.sansCaption)
                    .foregroundStyle(Color.themeSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.themeSecondary.opacity(0.08), lineWidth: 1)
            )
        }
    }
}

// MARK: - Size Card

/// Shows "+" with "Taille" label. Tap opens the size picker sheet.
/// Once picked, shows the size in large serif font. Tap again to change.
struct SizeCardView: View {
    @Binding var sizeText: String
    @Binding var isShowingPicker: Bool

    private var selectedSize: SizeOption? {
        SizeCatalog.find(by: sizeText)
    }

    var body: some View {
        Button { isShowingPicker = true } label: {
            VStack(spacing: 10) {
                Spacer()

                if let size = selectedSize {
                    Text(size.display)
                        .font(.serifTitle)
                        .fontWeight(.light)
                        .foregroundStyle(Color.themeSecondary)
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.themePrimary)
                        .frame(width: 50, height: 50)
                        .background(Color.themePrimary.opacity(0.12))
                        .clipShape(Circle())
                }

                Spacer()

                Text(selectedSize != nil ? String(localized: "size_placeholder") : String(localized: "size_placeholder"))
                    .font(.sansCaption)
                    .foregroundStyle(Color.themeSecondary)
                    .lineLimit(1)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.themeSecondary.opacity(0.08), lineWidth: 1)
            )
        }
    }
}

//
//  ModernGarmentFormView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 12/12/2025.
//

import SwiftUI
import CoreData
import UIKit
import AVFoundation

/// Form view for creating or editing a garment, including photos, metadata and status.
struct ModernGarmentFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

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
    @State private var isShowingCamera: Bool = false
    @State private var isShowingCameraDeniedAlert: Bool = false
    @State private var isShowingAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        photoSection
                        
                        VStack(spacing: 16) {
                            ModernTextField(title: String(localized: "title_required_placeholder"), text: $titleText)
                            ModernTextField(title: String(localized: "brand_placeholder"), text: $brandText)
                            HStack(spacing: 12) {
                                ModernTextField(title: String(localized: "size_placeholder"), text: $sizeText)
                                ModernTextField(title: String(localized: "color_placeholder"), text: $colorText)
                            }
                            ModernTextField(title: String(localized: "category_placeholder"), text: $categoryText)
                        }
                        
                        detailsSection
                        saveButton
                    }
                    .padding()
                }
            }
            .navigationTitle(editingGarment == nil ? String(localized: "new_garment") : String(localized: "edit"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel")) { dismiss() }
                }
            }
            .sheet(isPresented: $isShowingPicker) {
                ImagePickerMulti(images: $pickerSelectedImages)
            }
            .fullScreenCover(isPresented: $isShowingCamera) {
                CameraPicker { image in
                    let item = PhotoItem.new(image: image)
                    workingPhotoItems.append(item)
                }
            }
            .alert(String(localized: "camera_access_denied_title"), isPresented: $isShowingCameraDeniedAlert) {
                Button(String(localized: "camera_open_settings")) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button(String(localized: "cancel"), role: .cancel) {}
            } message: {
                Text(String(localized: "camera_access_denied_message"))
            }
            .onChange(of: pickerSelectedImages) { _, newImages in
                let items = newImages.map { PhotoItem.new(image: $0) }
                workingPhotoItems.append(contentsOf: items)
                pickerSelectedImages.removeAll()
            }
            .onAppear(perform: loadData)
            .alert(String(localized: "error_title"), isPresented: $isShowingAlert) {
                Button(String(localized: "ok"), role: .cancel) {}
            } message: { Text(alertMessage) }
        }
    }

    var photoSection: some View {
        VStack(alignment: .leading) {
            Text(String(localized: "photos_title"))
                .font(.sansCaption)
                .bold()
                .foregroundStyle(Color.themeSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Button { requestCameraAccess() } label: {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.serifTitle3)
                                .foregroundStyle(Color.themePrimary)
                            Text(String(localized: "photo_source_camera_short"))
                                .font(.sansCaption)
                                .foregroundStyle(Color.themePrimary)
                        }
                        .frame(width: 80, height: 100)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.themePrimary.opacity(0.3),
                                        style: StrokeStyle(dash: [5]))
                        )
                    }

                    Button { isShowingPicker = true } label: {
                        VStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.serifTitle3)
                                .foregroundStyle(Color.themePrimary)
                            Text(String(localized: "photo_source_library_short"))
                                .font(.sansCaption)
                                .foregroundStyle(Color.themePrimary)
                        }
                        .frame(width: 80, height: 100)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.themePrimary.opacity(0.3),
                                        style: StrokeStyle(dash: [5]))
                        )
                    }
                    
                    ForEach(Array(workingPhotoItems.enumerated()), id: \.element.id) { index, item in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: thumbnail(for: item))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Button {
                                workingPhotoItems.remove(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.red)
                                    .background(Circle().fill(.white))
                            }
                            .offset(x: 5, y: -5)
                        }
                    }
                }
            }
        }
    }
    
    var detailsSection: some View {
        VStack(alignment: .leading) {
            Text(String(localized: "details_title"))
                .font(.sansCaption)
                .bold()
                .foregroundStyle(Color.themeSecondary)
            
            VStack {
                HStack {
                    Text(String(localized: "status_title"))
                    Spacer()
                    Picker(String(localized: "status_title"), selection: $statusValue) {
                        ForEach(GarmentStatus.allCases) {
                            Text($0.label).tag($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color.themePrimary)
                }
                .padding()
                
                Divider()
                
                HStack {
                    Text(String(format: String(localized: "worn_count"), wearCount))
                    Spacer()
                    Stepper("", value: $wearCount, in: 0...999)
                        .labelsHidden()
                }
                .padding()
            }
            .background(Color.white)
            .cornerRadius(12)
        }
    }
    
    var saveButton: some View {
        Button { save() } label: {
            Text(String(localized: "save"))
                .bold()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(!titleText.isEmpty ? Color.themePrimary : Color.gray)
                .cornerRadius(16)
        }
        .disabled(titleText.isEmpty)
    }

    /// Returns the thumbnail for a photo item.
    func thumbnail(for item: PhotoItem) -> UIImage {
        switch item {
        case .existing(_, let t):
            return t
        case .new(let i):
            return i
        }
    }
    
    /// Requests camera access and presents the camera if authorized.
    func requestCameraAccess() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            alertMessage = String(localized: "camera_unavailable")
            isShowingAlert = true
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isShowingCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { isShowingCamera = true }
                }
            }
        case .denied, .restricted:
            isShowingCameraDeniedAlert = true
        @unknown default:
            break
        }
    }

    /// Loads garment data when editing.
    func loadData() {
        if let g = editingGarment {
            titleText = g.title ?? ""
            brandText = g.brand ?? ""
            colorText = g.color ?? ""
            sizeText = g.size ?? ""
            categoryText = g.category ?? ""
            notesText = g.notes ?? ""
            wearCount = g.wearCount
            statusValue = GarmentStatus(rawValue: g.statusRaw) ?? .kept
            workingPhotoItems = g.allLoadedImages.compactMap { item in
                guard let photo = g.orderedPhotos.first(where: { $0.id == item.id }) else { return nil }
                return .existing(photoObject: photo, thumbnail: item.image)
            }
        }
    }
    
    /// Saves the garment and dismisses.
    func save() {
        let controller = GarmentController(managedObjectContext: viewContext)
        do {
            if let g = editingGarment {
                try controller.update(
                    g,
                    title: titleText,
                    brand: brandText,
                    color: colorText,
                    size: sizeText,
                    category: categoryText,
                    notes: notesText,
                    wearCount: wearCount,
                    status: statusValue
                )
                
                let keptPhotos = workingPhotoItems.compactMap {
                    if case .existing(let obj, _) = $0 { return obj } else { return nil }
                }
                let toRemove = Array(g.photoSet).filter { !keptPhotos.contains($0) }
                if !toRemove.isEmpty {
                    try controller.removePhotos(toRemove, from: g)
                }
                
                let newImages = workingPhotoItems.compactMap {
                    if case .new(let i) = $0 { return i } else { return nil }
                }
                if !newImages.isEmpty {
                    _ = try controller.addPhotos(newImages, to: g)
                }
            } else if let d = selectedDressing {
                let newImages = workingPhotoItems.compactMap {
                    if case .new(let i) = $0 { return i } else { return nil }
                }
                _ = try controller.create(
                    in: d,
                    title: titleText,
                    brand: brandText,
                    color: colorText,
                    size: sizeText,
                    category: categoryText,
                    notes: notesText,
                    status: statusValue,
                    wearCount: wearCount,
                    photos: newImages
                )
            }
            dismiss()
        } catch {
            print(error)
        }
    }
}

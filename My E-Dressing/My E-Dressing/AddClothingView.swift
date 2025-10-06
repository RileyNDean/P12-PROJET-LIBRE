//
//  AddClothingView.swift
//  
//  This view allows users to add new clothing items by selecting a photo,
//  entering the name, notes, and choosing a status for the clothing item.
//  Persistence will be handled later by a dedicated controller.
//

import SwiftUI
import PhotosUI

/// Represents the status of a clothing item with localized display strings.
enum ClothingStatus: String, CaseIterable, Identifiable {
    case keep = "Keep"
    case donate = "Donate"
    case sell = "Sell"
    case recycle = "Recycle"

    var id: String { rawValue }
}

/// A view that lets users add a new clothing item with photo, name, status, and notes.
struct AddClothingView: View {
    @Environment(\.dismiss) private var dismiss

    // Selected photo picker item
    @State private var selectedPhoto: PhotosPickerItem?
    // Image created from selected photo data
    @State private var selectedImage: Image?

    // Clothing item properties
    @State private var name: String = ""
    @State private var notes: String = ""
    @State private var status: ClothingStatus = .keep

    var body: some View {
        NavigationStack {
            Form {
                // Section for selecting a photo of the clothing item
                Section("Photo") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        HStack {
                            if let selectedImage {
                                selectedImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 64, height: 64)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.15))
                                    Image(systemName: "photo")
                                        .foregroundStyle(.secondary)
                                }
                                .frame(width: 64, height: 64)
                            }
                            Text("Choose a photo")
                        }
                    }
                }

                // Section for entering clothing details
                Section("Information") {
                    TextField("Clothing name", text: $name)
                    Picker("Status", selection: $status) {
                        ForEach(ClothingStatus.allCases) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("Add")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // TODO: Persist the clothing item using a controller before dismissing
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .task(id: selectedPhoto) {
                // Load selected photo data and convert it to an Image
                guard let selectedPhoto else { return }
                if let data = try? await selectedPhoto.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = Image(uiImage: uiImage)
                }
            }
        }
    }
}

#Preview {
    AddClothingView()
}

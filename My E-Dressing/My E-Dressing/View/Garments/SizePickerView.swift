//
//  SizePickerView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 11/02/2026.
//

import SwiftUI

/// Full-screen size picker with search and sections.
/// Each size is displayed as a card with the size in a large, elegant serif font.
/// Each section has a "+" button to add a custom size.
struct SizePickerView: View {
    @Binding var selectedSizeId: String?
    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = ""
    @State private var addingSectionId: String? = nil
    @State private var newSizeText: String = ""
    @State private var refreshToggle: Bool = false

    private var currentSections: [SizeSection] {
        _ = refreshToggle
        return SizeCatalog.sections
    }

    private var filteredSections: [SizeSection] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        if query.isEmpty { return currentSections }
        return currentSections.compactMap { section in
            let filtered = section.sizes.filter { $0.display.lowercased().contains(query) }
            guard !filtered.isEmpty else { return nil }
            return SizeSection(id: section.id, titleKey: section.titleKey, sizes: filtered)
        }
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(Color.themeSecondary.opacity(0.4))
                            TextField(String(localized: "size_search"), text: $searchText)
                                .font(.sansBody)
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Color.themeSecondary.opacity(0.3))
                                }
                            }
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)

                        // Sections
                        ForEach(filteredSections) { section in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(String(localized: String.LocalizationValue(section.titleKey)))
                                    .font(.sansCaption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.themeSecondary.opacity(0.5))
                                    .padding(.leading, 4)

                                LazyVGrid(columns: columns, spacing: 10) {
                                    ForEach(section.sizes) { size in
                                        SizeCell(
                                            size: size,
                                            isSelected: selectedSizeId == size.id
                                        ) {
                                            selectedSizeId = size.id
                                            dismiss()
                                        }
                                    }

                                    // "+" button to add custom size
                                    AddSizeButton {
                                        addingSectionId = section.id
                                        newSizeText = ""
                                    }
                                }

                                // Inline text field when adding
                                if addingSectionId == section.id {
                                    HStack(spacing: 8) {
                                        TextField(String(localized: "size_custom_placeholder"), text: $newSizeText)
                                            .font(.sansBody)
                                            .padding(10)
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.themePrimary.opacity(0.3), lineWidth: 1)
                                            )
                                            .submitLabel(.done)
                                            .onSubmit { saveCustomSize(for: section.id) }

                                        Button {
                                            saveCustomSize(for: section.id)
                                        } label: {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 28))
                                                .foregroundStyle(Color.themePrimary)
                                        }

                                        Button {
                                            addingSectionId = nil
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 28))
                                                .foregroundStyle(Color.themeSecondary.opacity(0.3))
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            .padding(.horizontal)
                        }

                        Color.clear.frame(height: 40)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle(String(localized: "size_picker_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "size_picker_title"))
                        .font(.serifTitle3)
                        .foregroundStyle(Color.themeSecondary)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "category_clear")) {
                        selectedSizeId = nil
                        dismiss()
                    }
                    .font(.sansBody)
                    .foregroundStyle(Color.themePrimary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.themeSecondary.opacity(0.3))
                    }
                }
            }
        }
    }

    /// Persists the custom size and refreshes the view.
    private func saveCustomSize(for sectionId: String) {
        let trimmed = newSizeText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        SizeCatalog.addCustomSize(trimmed, toSection: sectionId)
        addingSectionId = nil
        newSizeText = ""
        refreshToggle.toggle()
    }
}

// MARK: - Size Cell

/// A card displaying the size in a large, elegant serif font.
private struct SizeCell: View {
    let size: SizeOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(size.display)
                .font(.serifTitle3)
                .fontWeight(.light)
                .foregroundStyle(isSelected ? Color.themePrimary : Color.themeSecondary)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(isSelected ? Color.themePrimary.opacity(0.1) : Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? Color.themePrimary.opacity(0.4) : Color.themeSecondary.opacity(0.08),
                            lineWidth: isSelected ? 1.5 : 1
                        )
                )
        }
    }
}

// MARK: - Add Size Button

/// Orange "+" button matching the size cell style.
private struct AddSizeButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.themePrimary)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(Color.themePrimary.opacity(0.08))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.themePrimary.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

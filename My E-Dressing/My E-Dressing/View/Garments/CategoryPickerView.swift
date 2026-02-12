//
//  CategoryPickerView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 11/02/2026.
//

import SwiftUI

/// Full-screen category picker displayed as a grid of icon cells grouped by section.
struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategoryId: String?

    @State private var searchText: String = ""

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(Color.themeSecondary.opacity(0.4))
                            TextField(String(localized: "category_search"), text: $searchText)
                                .font(.sansBody)
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.themeSecondary.opacity(0.08), lineWidth: 1)
                        )
                        .padding(.horizontal)

                        ForEach(filteredSections) { section in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(section.title)
                                    .font(.serifHeadline)
                                    .foregroundStyle(Color.themeSecondary)
                                    .padding(.leading, 4)

                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(section.categories) { category in
                                        CategoryCell(
                                            category: category,
                                            isSelected: selectedCategoryId == category.id
                                        ) {
                                            selectedCategoryId = category.id
                                            dismiss()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        Color.clear.frame(height: 20)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "category_placeholder"))
                        .font(.serifTitle3)
                        .foregroundStyle(Color.themeSecondary)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel")) { dismiss() }
                        .foregroundStyle(Color.themePrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if selectedCategoryId != nil {
                        Button {
                            selectedCategoryId = nil
                            dismiss()
                        } label: {
                            Text(String(localized: "category_clear"))
                                .font(.sansSubheadline)
                                .foregroundStyle(.red.opacity(0.8))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Filtering

    private var filteredSections: [CategorySection] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return GarmentCategoryCatalog.sections
        }
        let query = searchText.lowercased()
        return GarmentCategoryCatalog.sections.compactMap { section in
            let matched = section.categories.filter { $0.label.lowercased().contains(query) }
            return matched.isEmpty ? nil : CategorySection(id: section.id, titleKey: section.titleKey, categories: matched)
        }
    }
}

// MARK: - Category Cell

/// A single cell in the picker grid: icon on top, label below.
struct CategoryCell: View {
    let category: GarmentCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(category.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)

                Text(category.label)
                    .font(.sansCaption)
                    .foregroundStyle(Color.themeSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 6)
            .background(isSelected ? Color.themePrimary.opacity(0.12) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.themePrimary : Color.themeSecondary.opacity(0.08), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

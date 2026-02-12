//
//  SearchView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 11/02/2026.
//

import SwiftUI
import CoreData

/// Global search across all garments by title, brand, color, size, category and notes.
struct SearchView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Garment.createdAt, ascending: false)]
    ) private var allGarments: FetchedResults<Garment>

    @State private var searchText: String = ""
    @State private var expandedGarmentId: UUID? = nil
    @State private var editingGarment: Garment?

    private let searchController = SearchController()

    private var filteredGarments: [Garment] {
        searchController.search(garments: Array(allGarments), query: searchText)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: - Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.themeSecondary.opacity(0.4))
                        TextField(String(localized: "search_placeholder"), text: $searchText)
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.themeSecondary.opacity(0.08), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // MARK: - Results
                    if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                        // Empty state — no search yet
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundStyle(Color.themeSecondary.opacity(0.15))
                            Text(String(localized: "search_hint"))
                                .font(.sansSubheadline)
                                .foregroundStyle(Color.themeSecondary.opacity(0.4))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        Spacer()
                    } else if filteredGarments.isEmpty {
                        // No results
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "tshirt")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.themeSecondary.opacity(0.15))
                            Text(String(localized: "search_no_results"))
                                .font(.sansSubheadline)
                                .foregroundStyle(Color.themeSecondary.opacity(0.4))
                        }
                        Spacer()
                    } else {
                        // Results list
                        ScrollView {
                            VStack(spacing: 0) {
                                Text(String(format: String(localized: "search_results_count"), filteredGarments.count))
                                    .font(.sansCaption2)
                                    .foregroundStyle(Color.themeSecondary.opacity(0.4))
                                    .padding(.top, 12)
                                    .padding(.bottom, 4)

                                ForEach(filteredGarments) { garment in
                                    ModernGarmentRow(
                                        garment: garment,
                                        expandedGarmentId: $expandedGarmentId,
                                        onEdit: { editingGarment = garment }
                                    )
                                }

                                Color.clear.frame(height: 100)
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "tab_search"))
                        .font(.serifTitle3)
                        .foregroundStyle(Color.themeSecondary)
                }
            }
            .sheet(item: $editingGarment) { garment in
                GarmentFormView(editingGarment: garment)
            }
        }
    }

}

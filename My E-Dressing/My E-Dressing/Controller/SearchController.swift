//
//  SearchController.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 11/02/2026.
//

import Foundation

/// Handles garment search/filtering logic.
/// Keeps business logic out of the View layer.
final class SearchController {

    /// Filters garments matching the given query across all fields.
    /// - Parameters:
    ///   - garments: The full list of garments to search.
    ///   - query: The user's search text.
    /// - Returns: Filtered garments matching the query.
    func search(garments: [Garment], query: String) -> [Garment] {
        let trimmed = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !trimmed.isEmpty else { return [] }

        return garments.filter { garment in
            let fields: [String?] = [
                garment.title,
                garment.brand,
                garment.color,
                garment.size,
                garment.notes,
                GarmentCategoryCatalog.find(by: garment.category)?.label,
                GarmentStatus(rawValue: garment.statusRaw)?.label
            ]
            return fields.contains { $0?.lowercased().contains(trimmed) == true }
        }
    }
}

//
//  SizeCatalog.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 11/02/2026.
//

import Foundation

/// Represents a single size option.
struct SizeOption: Identifiable, Hashable {
    let id: String          // stored in Core Data (e.g. "M", "42", "44")
    let display: String     // shown to user (same as id for sizes)
}

/// A section of sizes grouped by type.
struct SizeSection: Identifiable {
    let id: String
    let titleKey: String
    let sizes: [SizeOption]
}

/// Catalog of all French standard clothing sizes.
/// Also manages user-added custom sizes persisted via UserDefaults.
enum SizeCatalog {

    private static let customSizesKey = "customSizes"

    // MARK: - Letter Sizes
    static let letterSizes: [SizeOption] = [
        SizeOption(id: "XXS", display: "XXS"),
        SizeOption(id: "XS", display: "XS"),
        SizeOption(id: "S", display: "S"),
        SizeOption(id: "M", display: "M"),
        SizeOption(id: "L", display: "L"),
        SizeOption(id: "XL", display: "XL"),
        SizeOption(id: "XXL", display: "XXL"),
        SizeOption(id: "3XL", display: "3XL")
    ]

    // MARK: - EU Number Sizes (Tops / Bottoms)
    static let euSizes: [SizeOption] = [
        SizeOption(id: "32", display: "32"),
        SizeOption(id: "34", display: "34"),
        SizeOption(id: "36", display: "36"),
        SizeOption(id: "38", display: "38"),
        SizeOption(id: "40", display: "40"),
        SizeOption(id: "42", display: "42"),
        SizeOption(id: "44", display: "44"),
        SizeOption(id: "46", display: "46"),
        SizeOption(id: "48", display: "48"),
        SizeOption(id: "50", display: "50"),
        SizeOption(id: "52", display: "52"),
        SizeOption(id: "54", display: "54"),
        SizeOption(id: "56", display: "56")
    ]

    // MARK: - Shoe Sizes (EU)
    static let shoeSizes: [SizeOption] = [
        SizeOption(id: "35", display: "35"),
        SizeOption(id: "36", display: "36"),
        SizeOption(id: "37", display: "37"),
        SizeOption(id: "38", display: "38"),
        SizeOption(id: "39", display: "39"),
        SizeOption(id: "40", display: "40"),
        SizeOption(id: "41", display: "41"),
        SizeOption(id: "42", display: "42"),
        SizeOption(id: "43", display: "43"),
        SizeOption(id: "44", display: "44"),
        SizeOption(id: "45", display: "45"),
        SizeOption(id: "46", display: "46"),
        SizeOption(id: "47", display: "47")
    ]

    // MARK: - Jeans (waist)
    static let jeansSizes: [SizeOption] = [
        SizeOption(id: "W24", display: "W24"),
        SizeOption(id: "W25", display: "W25"),
        SizeOption(id: "W26", display: "W26"),
        SizeOption(id: "W27", display: "W27"),
        SizeOption(id: "W28", display: "W28"),
        SizeOption(id: "W29", display: "W29"),
        SizeOption(id: "W30", display: "W30"),
        SizeOption(id: "W31", display: "W31"),
        SizeOption(id: "W32", display: "W32"),
        SizeOption(id: "W33", display: "W33"),
        SizeOption(id: "W34", display: "W34"),
        SizeOption(id: "W36", display: "W36")
    ]

    // MARK: - Unique / One Size
    static let uniqueSize: [SizeOption] = [
        SizeOption(id: "TU", display: "TU")
    ]

    // MARK: - All Sections (including custom sizes)

    static var sections: [SizeSection] {
        let custom = loadCustomSizes()
        let baseSections: [(String, String, [SizeOption])] = [
            ("letter", "size_section_letter", letterSizes),
            ("eu", "size_section_eu", euSizes),
            ("shoes", "size_section_shoes", shoeSizes),
            ("jeans", "size_section_jeans", jeansSizes),
            ("unique", "size_section_unique", uniqueSize)
        ]

        var result: [SizeSection] = baseSections.map { id, titleKey, sizes in
            let extras = custom[id] ?? []
            return SizeSection(id: id, titleKey: titleKey, sizes: sizes + extras)
        }

        // "Mes tailles" section for custom sizes that don't belong to a specific section
        let generalCustom = custom["custom"] ?? []
        if !generalCustom.isEmpty {
            result.append(SizeSection(id: "custom", titleKey: "size_section_custom", sizes: generalCustom))
        }

        return result
    }

    static var allSizes: [SizeOption] {
        sections.flatMap(\.sizes)
    }

    /// Finds a size by its ID.
    static func find(by id: String?) -> SizeOption? {
        guard let id, !id.isEmpty else { return nil }
        if let found = allSizes.first(where: { $0.id == id }) {
            return found
        }
        // If not found, it might be an old custom size — return it as-is
        return SizeOption(id: id, display: id)
    }

    // MARK: - Custom Size Persistence

    /// Adds a custom size to a section.
    static func addCustomSize(_ value: String, toSection sectionId: String) {
        var custom = loadCustomSizes()
        var list = custom[sectionId] ?? []
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        guard !list.contains(where: { $0.id == trimmed }) else { return }
        // Also skip if already exists as built-in
        let allBuiltIn = letterSizes + euSizes + shoeSizes + jeansSizes + uniqueSize
        guard !allBuiltIn.contains(where: { $0.id == trimmed }) else { return }
        list.append(SizeOption(id: trimmed, display: trimmed))
        custom[sectionId] = list
        saveCustomSizes(custom)
    }

    /// Loads custom sizes from UserDefaults.
    private static func loadCustomSizes() -> [String: [SizeOption]] {
        guard let data = UserDefaults.standard.dictionary(forKey: customSizesKey) as? [String: [String]] else {
            return [:]
        }
        return data.mapValues { ids in ids.map { SizeOption(id: $0, display: $0) } }
    }

    /// Persists custom sizes to UserDefaults.
    private static func saveCustomSizes(_ sizes: [String: [SizeOption]]) {
        let data = sizes.mapValues { options in options.map(\.id) }
        UserDefaults.standard.set(data, forKey: customSizesKey)
    }
}

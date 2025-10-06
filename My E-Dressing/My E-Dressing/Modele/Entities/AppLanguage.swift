//
//  AppLanguage.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

/// Model Layer: Defines the app's supported languages and related helpers.

import Foundation

// MARK: - AppLanguage
enum AppLanguage: String, CaseIterable, Identifiable {
    /// Use the system's preferred language setting.
    case system
    /// English language.
    case en
    /// French language.
    case fr

    /// Stable identifier used by SwiftUI lists and selections.
    var id: String { rawValue }

    /// Human-readable label for UI display.
    var label: String {
        switch self {
        case .system: return "System"
        case .en: return "English"
        case .fr: return "Français"
        }
    }

    /// The `Locale` to apply for this language, or `nil` to follow system settings.
    var locale: Locale? {
        switch self {
        case .system: return nil
        case .en: return Locale(identifier: "en")
        case .fr: return Locale(identifier: "fr")
        }
    }
}

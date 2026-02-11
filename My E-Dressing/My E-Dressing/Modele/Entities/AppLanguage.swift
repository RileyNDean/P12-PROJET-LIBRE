//
//  AppLanguage.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case en
    case fr

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .en: return "English"
        case .fr: return "Français"
        }
    }

    var locale: Locale? {
        switch self {
        case .system: return nil
        case .en: return Locale(identifier: "en")
        case .fr: return Locale(identifier: "fr")
        }
    }
}

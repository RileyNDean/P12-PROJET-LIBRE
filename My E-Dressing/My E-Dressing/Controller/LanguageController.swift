//
//  LanguageController.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import Foundation
import Combine

/// Orchestrates language selection. Owns persistence and exposes the active Locale.
final class LanguageController: ObservableObject {
    @Published private(set) var selected: AppLanguage
    private let key = "appLanguage"
    private let defaults: UserDefaults

    /// Loads persisted language or defaults to `.system`.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let raw = defaults.string(forKey: key), let lang = AppLanguage(rawValue: raw) {
            self.selected = lang
        } else { self.selected = .system }
    }

    /// Current Locale to inject in SwiftUI environment.
    var currentLocale: Locale {
        selected.locale ?? Locale.current
    }

    /// Sets and persists a new language.
    /// - Parameter lang: AppLanguage chosen by the user.
    func setLanguage(_ lang: AppLanguage) {
        selected = lang
        defaults.set(lang.rawValue, forKey: key)
    }
}

//
//  LanguageController.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import Foundation
import Combine

/// Manages language selection and persistence via UserDefaults.
final class LanguageController: ObservableObject {
    @Published private(set) var selected: AppLanguage
    private let key = "appLanguage"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let raw = defaults.string(forKey: key), let lang = AppLanguage(rawValue: raw) {
            self.selected = lang
        } else { self.selected = .system }
    }

    var currentLocale: Locale {
        selected.locale ?? Locale.current
    }

    func setLanguage(_ lang: AppLanguage) {
        selected = lang
        defaults.set(lang.rawValue, forKey: key)
    }
}

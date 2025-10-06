//
//  LanguageSettingsView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import SwiftUI

/// Settings screen to choose the preferred app language.
/// The available languages are defined by `AppLanguage`.
struct LanguageSettingsView: View {
    /// Persisted app language key stored in UserDefaults via AppStorage.
    @AppStorage("appLanguage") private var appLang: String = AppLanguage.system.rawValue

    /// The view body rendering a selectable list of languages.
    var body: some View {
        List {
            ForEach(AppLanguage.allCases) { language in
                HStack {
                    Text(language.label)
                    Spacer()
                    if appLang == language.rawValue { Image(systemName: "checkmark") }
                }
                .contentShape(Rectangle())
                // Update the persisted language when the row is tapped.
                .onTapGesture { appLang = language.rawValue }
            }
        }
        .navigationTitle(String(localized: "name")) 
    }
}


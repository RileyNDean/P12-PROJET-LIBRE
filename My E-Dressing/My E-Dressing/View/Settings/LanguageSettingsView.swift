//
//  LanguageSettingsView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import SwiftUI

/// Displays a simple list allowing the user to select the app language.
/// The available languages are defined by `AppLanguage` (see AppLanguage.swift).

/// A settings screen to choose the preferred app language.
struct LanguageSettingsView: View {
    /// Persisted app language key stored in UserDefaults via AppStorage.
    @AppStorage("appLanguage") private var appLang: String = AppLanguage.system.rawValue

    /// The view body rendering a selectable list of languages.
    var body: some View {
        List {
            ForEach(AppLanguage.allCases) { lang in
                HStack {
                    Text(lang.label)
                    Spacer()
                    if appLang == lang.rawValue { Image(systemName: "checkmark") }
                }
                .contentShape(Rectangle())
                // Update the persisted language when the row is tapped.
                .onTapGesture { appLang = lang.rawValue }
            }
        }
        .navigationTitle(String(localized: "name")) 
    }
}

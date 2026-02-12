//
//  LanguageSettingsView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import SwiftUI

/// Screen allowing the user to choose the application language.
struct LanguageSettingsView: View {
    @AppStorage("appLanguage") private var appLang: String = AppLanguage.system.rawValue

    var body: some View {
        List {
            ForEach(AppLanguage.allCases) { language in
                HStack {
                    Text(language.label)
                    Spacer()
                    if appLang == language.rawValue { Image(systemName: "checkmark") }
                }
                .contentShape(Rectangle())
                .onTapGesture { appLang = language.rawValue }
            }
        }
        .navigationTitle(String(localized: "settings_language_title"))
    }
}


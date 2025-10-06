//
//  My_E_DressingApp.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import SwiftUI
import CoreData

/// Application entry point.
/// Injects the Core Data `viewContext` and the `LanguageController` into the SwiftUI environment.
struct My_E_DressingApp: App {
    /// Shared Core Data stack for the application.
    let persistenceController = PersistenceController.shared
    
    /// Global language controller that manages the current app locale.
    @StateObject private var lang = LanguageController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.locale, lang.currentLocale)   
                .environmentObject(lang)
        }
    }
}

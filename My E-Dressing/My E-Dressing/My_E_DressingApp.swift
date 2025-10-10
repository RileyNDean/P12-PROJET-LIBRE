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
@main
struct My_E_DressingApp: App {
    let pc = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DressingListView()
            }
            .environment(\.managedObjectContext, pc.container.viewContext)
        }
    }
}

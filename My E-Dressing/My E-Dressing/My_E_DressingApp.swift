//
//  My_E_DressingApp.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

// This file contains the main entry point of the MEDressing app and sets up the Core Data environment.

import SwiftUI
import CoreData

@main
/// Application entry point for the MEDressing app.
struct MEDressingApp: App {
    // Shared Core Data stack used across the app.
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

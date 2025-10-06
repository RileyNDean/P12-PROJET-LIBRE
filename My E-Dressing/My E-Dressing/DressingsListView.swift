//
// DressingsListView.swift
// This view lists all dressings.
//

import SwiftUI

/// A placeholder list of dressings.
/// This view will be wired to a controller and will not access the model directly.
struct DressingsListView: View {
    var body: some View {
        List {
            Section("My dressings") {
                // Placeholder: Core Data-backed dressings will be displayed here via a controller
                Text("Main dressing")
            }
        }
        .navigationTitle("Dressings")
    }
}

#Preview {
    NavigationStack { DressingsListView() }
}

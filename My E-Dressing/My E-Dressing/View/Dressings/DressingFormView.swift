//
//  DressingFormView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 10/10/2025.
//

import SwiftUI
import CoreData

struct DressingFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var managedObjectContext

    var editingDressing: Dressing? = nil
    var onSaved: ((Dressing) -> Void)? = nil

    @State private var nameText = ""

    var body: some View {
        NavigationStack {
            Form { TextField(String(localized: "name"), text: $nameText) }
                .navigationTitle(editingDressing == nil ? String(localized: "new_dressing")
                                                        : String(localized: "rename"))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "cancel")) { dismiss() }
                    }
                }
                .floatingButtonCentered(title: String(localized: "save"),
                                        systemImage: "checkmark") { save() }

        }
        .onAppear { if let dressing = editingDressing { nameText = dressing.name ?? "" } }
    }

    private func save() {
        do {
            let dressingController = DressingController(managedObjectContext: managedObjectContext)
            let savedDressing: Dressing
            if let dressing = editingDressing {
                try dressingController.rename(dressing, to: nameText)
                savedDressing = dressing
            } else {
                savedDressing = try dressingController.create(name: nameText)
            }
            dismiss()
            onSaved?(savedDressing)
        } catch {}
    }
}


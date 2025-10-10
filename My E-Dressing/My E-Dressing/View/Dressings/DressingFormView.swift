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
    @Environment(\.managedObjectContext) private var context

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
                .floatingButton(title: String(localized: "save"), systemImage: "checkmark") { save() }
        }
        .onAppear { if let d = editingDressing { nameText = d.name ?? "" } }
    }

    private func save() {
        do {
            let controller = DressingController(managedObjectContext: context)
            let result: Dressing
            if let d = editingDressing {
                try controller.rename(d, to: nameText)
                result = d
            } else {
                result = try controller.create(name: nameText)
            }
            dismiss()
            onSaved?(result)
        } catch {}
    }
}


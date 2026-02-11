//
//  ModernDressingFormView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 12/12/2025.
//

import SwiftUI
import CoreData

struct ModernDressingFormView: View {
    @Environment(\.managedObjectContext) var viewContext

    var editingDressing: Dressing? = nil
    var onDismiss: () -> Void

    @State private var name: String = ""

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.themePrimary.opacity(0.1))
                        .frame(width: 80, height: 80)

                    Image(systemName: "cabinet.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.themePrimary)
                }

                Text(editingDressing == nil ? String(localized: "new_dressing") : String(localized: "edit"))
                    .font(.title2.bold())
                    .foregroundStyle(Color.themeSecondary)
            }

            ModernTextField(title: String(localized: "dressing_name"), text: $name)

            HStack(spacing: 16) {
                Button {
                    onDismiss()
                } label: {
                    Text(String(localized: "cancel"))
                        .font(.headline)
                        .foregroundStyle(Color.themeSecondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                }

                Button {
                    save()
                } label: {
                    Text(editingDressing == nil ? String(localized: "create") : String(localized: "update"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(name.isEmpty ? Color.gray.opacity(0.3) : Color.themePrimary)
                        .cornerRadius(16)
                }
                .disabled(name.isEmpty)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 24)
        .onAppear {
            if let d = editingDressing { name = d.name ?? "" }
        }
    }

    func save() {
        let controller = DressingController(managedObjectContext: viewContext)
        do {
            if let d = editingDressing { try controller.rename(d, to: name) }
            else { try controller.create(name: name) }
            onDismiss()
        } catch { print(error) }
    }
}

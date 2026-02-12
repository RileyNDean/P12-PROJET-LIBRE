//
//  ModernDressingFormView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 12/12/2025.
//

import SwiftUI
import CoreData

/// Overlay form for creating or editing a dressing (icon, color, name).
struct ModernDressingFormView: View {
    @Environment(\.managedObjectContext) var viewContext

    var editingDressing: Dressing? = nil
    var onDismiss: () -> Void

    @State private var name: String = ""
    @State private var selectedIcon: String = DressingIcon.defaultIcon
    @State private var selectedColorHex: String = DressingColor.defaultHex
    @State private var showIconPicker: Bool = false

    private var selectedColor: Color { Color(hex: selectedColorHex) }

    var body: some View {
        VStack(spacing: 24) {

            // MARK: - Icon (tappable)
            VStack(spacing: 12) {
                Button { withAnimation(.easeInOut(duration: 0.2)) { showIconPicker.toggle() } } label: {
                    ZStack {
                        Circle()
                            .fill(selectedColor.opacity(0.15))
                            .frame(width: 80, height: 80)

                        Image(systemName: selectedIcon)
                            .font(.system(size: 36))
                            .foregroundStyle(selectedColor)
                    }
                }

                Text(editingDressing == nil ? String(localized: "new_dressing") : String(localized: "edit"))
                    .font(.serifTitle)
                    .foregroundStyle(Color.themeSecondary)
            }

            // MARK: - Icon Picker Grid
            if showIconPicker {
                let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(DressingIcon.all, id: \.self) { icon in
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) { selectedIcon = icon }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedIcon == icon ? selectedColor.opacity(0.15) : Color.gray.opacity(0.06))
                                    .frame(height: 52)

                                Image(systemName: icon)
                                    .font(.system(size: 22))
                                    .foregroundStyle(selectedIcon == icon ? selectedColor : Color.themeSecondary.opacity(0.4))
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedIcon == icon ? selectedColor : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // MARK: - Color Picker Row
            HStack(spacing: 10) {
                ForEach(DressingColor.all, id: \.hex) { item in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { selectedColorHex = item.hex }
                    } label: {
                        Circle()
                            .fill(Color(hex: item.hex))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: selectedColorHex == item.hex ? 3 : 0)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: item.hex).opacity(0.6), lineWidth: selectedColorHex == item.hex ? 2 : 0)
                                    .padding(-2)
                            )
                    }
                }
            }

            // MARK: - Name Field
            ModernTextField(title: String(localized: "dressing_name"), text: $name)

            // MARK: - Buttons
            HStack(spacing: 16) {
                Button {
                    onDismiss()
                } label: {
                    Text(String(localized: "cancel"))
                        .font(.sansHeadline)
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
                        .font(.sansHeadline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(name.isEmpty ? Color.gray.opacity(0.3) : selectedColor)
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
            if let d = editingDressing {
                name = d.name ?? ""
                selectedIcon = d.iconName ?? DressingIcon.defaultIcon
                selectedColorHex = d.colorHex ?? DressingColor.defaultHex
            }
        }
    }

    /// Validates and persists the dressing via DressingController, then dismisses.
    func save() {
        let controller = DressingController(managedObjectContext: viewContext)
        do {
            if let d = editingDressing {
                try controller.update(d, name: name, iconName: selectedIcon, colorHex: selectedColorHex)
            } else {
                try controller.create(name: name, iconName: selectedIcon, colorHex: selectedColorHex)
            }
            onDismiss()
        } catch { print(error) }
    }
}

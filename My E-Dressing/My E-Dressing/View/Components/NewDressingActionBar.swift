//
//  NewDressingActionBar.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 11/12/2025.
//

import SwiftUI

struct NewDressingActionBar: View {
    let isExpanded: Bool
    let onCreate: () -> Void
    let onCancel: () -> Void
    let onTapCollapsed: () -> Void

    var body: some View {
        Group {
            if isExpanded {
                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text("Annuler")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.secondary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                            )
                    }

                    Button(action: onCreate) {
                        Label("Créer", systemImage: "checkmark")
                            .font(AppTheme.bodyFont.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(AppTheme.primary)
                            )
                    }
                }
                .padding(.bottom, AppTheme.paddingLarge)
            } else {
                FloatingActionButton(
                    icon: "plus",
                    label: "Nouveau dressing",
                    action: onTapCollapsed
                )
                .padding(.trailing, AppTheme.paddingMedium)
                .padding(.bottom, AppTheme.paddingLarge)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isExpanded)
    }
}

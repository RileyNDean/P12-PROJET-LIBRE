//
//  DeleteConfirmationDialog.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 12/02/2026.
//

import SwiftUI

/// Custom themed confirmation dialog for deletion actions.
struct DeleteConfirmationDialog: View {
    let message: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 20) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.themeSecondary)

                Text(String(localized: "confirm_delete_dressing_title"))
                    .font(.serifTitle3)
                    .foregroundStyle(Color.themeSecondary)

                Text(message)
                    .font(.sansBody)
                    .foregroundStyle(Color.themeSecondary.opacity(0.7))
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text(String(localized: "cancel"))
                            .font(.sansHeadline)
                            .foregroundColor(Color.themeSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.themeSecondary.opacity(0.1))
                            .cornerRadius(12)
                    }

                    Button(action: onConfirm) {
                        Text(String(localized: "delete"))
                            .font(.sansHeadline)
                            .foregroundColor(Color.themeSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.themePrimary.opacity(0.2))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(24)
            .background(Color.themeBackground)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 40)
        }
    }
}

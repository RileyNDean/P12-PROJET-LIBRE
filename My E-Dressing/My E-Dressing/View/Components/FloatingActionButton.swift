//
//  FloatingActionButton.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 11/12/2025.
//

import SwiftUI

struct FloatingActionButton: View {
    let icon: String
    let label: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))

                if let label {
                    Text(label)
                        .font(AppTheme.captionFont.weight(.semibold))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, label == nil ? 18 : 20)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.primary,
                                AppTheme.primary.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 6)
            .scaleEffect(1.0)
        }
        .buttonStyle(.plain)
    }
}


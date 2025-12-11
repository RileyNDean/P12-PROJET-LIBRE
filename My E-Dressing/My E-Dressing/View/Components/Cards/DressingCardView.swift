//
//  DressingCardView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 11/12/2025.
//

import SwiftUI

struct DressingCardView: View {
    let name: String
    let itemCount: Int
    let icon: String?

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.primary.opacity(0.15))

                if let icon, !icon.isEmpty {
                    Text(icon)
                        .font(.system(size: 24))
                } else {
                    Text(String(name.prefix(1)).uppercased())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                }
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(AppTheme.headlineFont)
                    .foregroundColor(.black)

                Text("\(itemCount) vêtement\(itemCount > 1 ? "s" : "")")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.horizontal, AppTheme.paddingMedium)
        .padding(.vertical, AppTheme.paddingSmall)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .fill(AppTheme.cardBackground)
        )
        .appShadow()
    }
}

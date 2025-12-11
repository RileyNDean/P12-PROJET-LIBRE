//
//  EmptyDressingsView.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 11/12/2025.
//

import SwiftUI

struct EmptyDressingsView: View {
    let onAddTapped: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cabinet")
                .font(.system(size: 40, weight: .regular))
                .foregroundColor(AppTheme.secondary.opacity(0.7))

            Text("Aucun dressing pour l’instant")
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.secondary)

            Text("Crée un premier dressing pour organiser tes vêtements par saison, style ou pièce.")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            Button(action: onAddTapped) {
                Text("Créer mon premier dressing")
                    .font(AppTheme.bodyFont.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule().fill(AppTheme.primary)
                    )
                    .appShadow()
            }
        }
        .padding(AppTheme.paddingLarge)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .fill(AppTheme.cardBackground)
        )
        .appShadow()
    }
}

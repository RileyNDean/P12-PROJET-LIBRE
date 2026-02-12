//
//  FloatingPrimaryButton.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 10/10/2025.
//

import SwiftUI

/// A circular floating action button with an icon and a label below it.
struct FloatingPrimaryButton: View {
    let systemImage: String
    let title: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Button(action: action) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding(18)
                    .background(Circle().fill(Color.accentColor))
                    .shadow(radius: 3)
            }
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .accessibilityIdentifier("floatingPrimaryButton")
    }
}

extension View {
    /// Convenience View modifier that overlays a centered floating button at the bottom.
    func floatingButtonCentered(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        overlay(
            VStack {
                Spacer()
                HStack { Spacer() }
                FloatingPrimaryButton(systemImage: systemImage, title: title, action: action)
                    .padding(.bottom, 24)
            }
        , alignment: .bottom)
    }
}


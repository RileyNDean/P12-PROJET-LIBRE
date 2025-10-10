//
//  FloatingPrimaryButton.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 10/10/2025.
//

import SwiftUI

struct FloatingPrimaryButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(.tint)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(radius: 3)
        }
        .accessibilityIdentifier("floatingPrimaryButton")
    }
}

extension View {
    func floatingButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        self.overlay(
            VStack {
                Spacer()
                HStack { Spacer()
                    FloatingPrimaryButton(title: title, systemImage: systemImage, action: action)
                        .padding(.trailing, 20).padding(.bottom, 20)
                }
            }
        )
    }
}

//
//  AppTheme.swift
//  My E-Dressing
//
//  Created by Claude Code
//  Theme: Organic & Modern
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors

    /// Fond principal - Crème Vanille (#FAFAF5)
    static let background = Color(hex: "FAFAF5")

    /// Couleur primaire - Terracotta / Orange Brûlé (#D96C45)
    static let primary = Color(hex: "D96C45")

    /// Couleur secondaire - Vert Forêt (#2F4842)
    static let secondary = Color(hex: "2F4842")

    /// Blanc pur pour les cartes et champs
    static let cardBackground = Color.white

    /// Gris doux pour les sous-titres
    static let textSecondary = Color(hex: "8A8A8A")

    /// Gris très clair pour les bordures
    static let borderColor = Color(hex: "E5E5E5")

    // MARK: - Typography

    static let titleFont = Font.system(size: 24, weight: .bold)
    static let headlineFont = Font.system(size: 18, weight: .semibold)
    static let bodyFont = Font.system(size: 16, weight: .regular)
    static let captionFont = Font.system(size: 14, weight: .regular)
    static let smallFont = Font.system(size: 12, weight: .regular)

    // MARK: - Spacing

    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
    static let paddingXLarge: CGFloat = 32

    // MARK: - Corner Radius

    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusXLarge: CGFloat = 20

    // MARK: - Shadows

    static let shadowLight = Shadow(
        color: Color.black.opacity(0.08),
        radius: 8,
        x: 0,
        y: 2
    )

    static let shadowMedium = Shadow(
        color: Color.black.opacity(0.12),
        radius: 12,
        x: 0,
        y: 4
    )

    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Color Extension (Hex Support)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension View {
    func appShadow(_ shadow: AppTheme.Shadow = AppTheme.shadowLight) -> some View {
        self.shadow(color: shadow.color,
                    radius: shadow.radius,
                    x: shadow.x,
                    y: shadow.y)
    }
}

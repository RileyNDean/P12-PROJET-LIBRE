//
//  AppTheme.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 12/12/2025.
//

import SwiftUI

// MARK: - Theme Colors ("Organic & Classy" palette)
extension Color {
    static let themeBackground = Color(hex: "FAFAF5")
    static let themePrimary = Color(hex: "D96C45")
    static let themeSecondary = Color(hex: "2F4842")
    static let themeAccent = Color(hex: "8F9E91")

    /// Creates a `Color` from a hexadecimal string (supports RGB, RRGGBB, AARRGGBB).
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
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography

extension Font {
    // -- Serif (elegant headings) --

    static let serifLargeTitle = Font.custom("Georgia-Bold", size: 28)
    static let serifTitle = Font.custom("Georgia-Bold", size: 22)
    static let serifTitle3 = Font.custom("Georgia-Bold", size: 18)
    static let serifHeadline = Font.custom("Georgia", size: 16)

    // -- Sans-serif (readable body text) --

    static let sansBody = Font.system(size: 16, weight: .regular)
    static let sansBodyMedium = Font.system(size: 16, weight: .medium)
    static let sansSubheadline = Font.system(size: 14, weight: .regular)
    static let sansHeadline = Font.system(size: 15, weight: .semibold)
    static let sansCaption = Font.system(size: 12, weight: .regular)
    static let sansCaption2 = Font.system(size: 11, weight: .regular)
    static let sansFootnote = Font.system(size: 13, weight: .regular)
}

// MARK: - Dressing Customization

/// Available SF Symbol icons for dressing personalization.
enum DressingIcon {
    static let all: [String] = [
        "cabinet.fill", "tshirt.fill", "shoe.fill",
        "bag.fill", "handbag.fill", "backpack.fill",
        "hanger", "eyeglasses", "figure.stand",
        "hat.widebrim.fill", "shoeprints.fill", "figure.stand.dress",
        "figure.child", "heart.fill", "dog.fill",
        "sparkles"
    ]
    static let defaultIcon = "cabinet.fill"
}

/// Available pastel colors (hex) for dressing personalization.
enum DressingColor {
    static let all: [(hex: String, name: String)] = [
        ("D96C45", "Terracotta"),
        ("E8A87C", "Peach"),
        ("D4A373", "Sand"),
        ("A7C4A0", "Sage"),
        ("8FBCBB", "Mint"),
        ("94B4C1", "Sky"),
        ("B4A7D6", "Lavender"),
        ("D4A5A5", "Rose"),
        ("C9B458", "Gold")
    ]
    static let defaultHex = "D96C45"
}

// MARK: - Card Style Modifier
/// Reusable card-style modifier applying white background, rounded corners and shadow.
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.themeSecondary.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: - Modern Text Field
/// A styled text field with a title label above it.
struct ModernTextField: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.sansCaption)
                .foregroundStyle(Color.themeSecondary)
                .padding(.leading, 4)
            
            TextField("", text: $text)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.themeSecondary.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

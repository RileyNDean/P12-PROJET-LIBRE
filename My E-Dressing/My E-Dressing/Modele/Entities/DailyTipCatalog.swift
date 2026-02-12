//
//  DailyTipCatalog.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 11/02/2026.
//

import Foundation

/// Model containing all daily awareness tips about responsible fashion.
/// Tips are selected deterministically based on the calendar day.
enum DailyTipCatalog {

    static let tips: [String] = [
        String(localized: "tip_1"),
        String(localized: "tip_2"),
        String(localized: "tip_3"),
        String(localized: "tip_4"),
        String(localized: "tip_5"),
        String(localized: "tip_6"),
        String(localized: "tip_7"),
        String(localized: "tip_8"),
        String(localized: "tip_9"),
        String(localized: "tip_10"),
        String(localized: "tip_11"),
        String(localized: "tip_12"),
        String(localized: "tip_13"),
        String(localized: "tip_14"),
        String(localized: "tip_15"),
        String(localized: "tip_16"),
        String(localized: "tip_17"),
        String(localized: "tip_18"),
        String(localized: "tip_19"),
        String(localized: "tip_20")
    ]

    static var todayTip: String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % tips.count
        return tips[index]
    }

    static var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale.current
        return formatter.string(from: Date())
    }
}

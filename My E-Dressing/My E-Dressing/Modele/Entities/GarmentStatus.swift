//
//  GarmentStatus.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import Foundation

/// Represents the lifecycle status of a garment (kept, to give, to sell, to recycle).
enum GarmentStatus: Int16, CaseIterable, Identifiable {
    case kept = 0, toGive = 1, toSell = 2, toRecycle = 3
    var id: Int16 { rawValue }
    var label: String {
        switch self {
        case .kept: String(localized: "status_kept")
        case .toGive: String(localized: "status_to_give")
        case .toSell: String(localized: "status_to_sell")
        case .toRecycle: String(localized: "status_to_recycle")
        }
    }
    var icon: String {
        switch self {
        case .kept: "checkmark.circle.fill"
        case .toGive: "gift.fill"
        case .toSell: "tag.fill"
        case .toRecycle: "arrow.3.trianglepath"
        }
    }
}

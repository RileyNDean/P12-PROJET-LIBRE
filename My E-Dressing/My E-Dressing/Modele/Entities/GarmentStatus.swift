//
//  GarmentStatus.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import Foundation

enum GarmentStatus: Int16, CaseIterable, Identifiable {
    case kept = 0, toGive = 1, toSell = 2, toRecycle = 3
    var id: Int16 { rawValue }
    var label: String {
        switch self {
        case .kept: "Kept"
        case .toGive: "To give"
        case .toSell: "To sell"
        case .toRecycle: "To recycle"
        }
    }
}

//
//  StatisticsController.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 11/02/2026.
//

import CoreData
import UIKit

/// Holds computed wardrobe statistics for the profile screen.
struct WardrobeStatistics {
    let totalCount: Int
    let neverWornCount: Int
    let toGiveCount: Int
    let toRecycleCount: Int
    let toSellCount: Int
    let keptCount: Int
    let avgWearCount: Double
    let categoryCount: Int
    let mostWornGarment: Garment?
    let neverWornPercentage: Int
}

/// Computes wardrobe statistics from a collection of garments.
final class StatisticsController {

    /// Computes all stats from the garment list.
    func computeStatistics(from garments: [Garment]) -> WardrobeStatistics {
        let total = garments.count

        let neverWorn = garments.filter { $0.wearCount == 0 }.count
        let toGive = garments.filter { $0.statusRaw == GarmentStatus.toGive.rawValue }.count
        let toRecycle = garments.filter { $0.statusRaw == GarmentStatus.toRecycle.rawValue }.count
        let toSell = garments.filter { $0.statusRaw == GarmentStatus.toSell.rawValue }.count
        let kept = garments.filter { $0.statusRaw == GarmentStatus.kept.rawValue }.count

        let avgWear: Double = total > 0
            ? Double(garments.reduce(0) { $0 + Int($1.wearCount) }) / Double(total)
            : 0

        let categories = Set(garments.compactMap { $0.category }).count
        let mostWorn = garments.max(by: { $0.wearCount < $1.wearCount })
        let percentage = total > 0 ? Int(Double(neverWorn) / Double(total) * 100) : 0

        return WardrobeStatistics(
            totalCount: total,
            neverWornCount: neverWorn,
            toGiveCount: toGive,
            toRecycleCount: toRecycle,
            toSellCount: toSell,
            keptCount: kept,
            avgWearCount: avgWear,
            categoryCount: categories,
            mostWornGarment: mostWorn,
            neverWornPercentage: percentage
        )
    }
}

//
//  StatisticsControllerTests.swift
//  My E-DressingTests
//
//  Created by Dhayan Bourguignon on 12/02/2026.
//

import XCTest
import CoreData
@testable import My_E_Dressing

final class StatisticsControllerTests: XCTestCase {

    private var persistenceController: PersistenceController!
    private var context: NSManagedObjectContext!
    private var statsController: StatisticsController!
    private var dressing: Dressing!

    private func makeGarment(
        title: String, status: GarmentStatus = .kept,
        wearCount: Int32 = 0, category: String? = nil
    ) -> Garment {
        let garment = Garment(context: context)
        garment.id = UUID()
        garment.title = title
        garment.statusRaw = status.rawValue
        garment.wearCount = wearCount
        garment.category = category
        garment.createdAt = Date()
        garment.dressing = dressing
        return garment
    }

    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        statsController = StatisticsController()

        dressing = Dressing(context: context)
        dressing.id = UUID()
        dressing.name = "Test"
        dressing.createdAt = Date()
        try? context.save()
    }

    // MARK: - Empty collection

    func testComputeWithEmptyArray() {
        let stats = statsController.computeStatistics(from: [])

        XCTAssertEqual(stats.totalCount, 0)
        XCTAssertEqual(stats.neverWornCount, 0)
        XCTAssertEqual(stats.avgWearCount, 0)
        XCTAssertEqual(stats.categoryCount, 0)
        XCTAssertNil(stats.mostWornGarment)
        XCTAssertEqual(stats.neverWornPercentage, 0)
    }

    // MARK: - Total count

    func testTotalCount() {
        let g1 = makeGarment(title: "A")
        let g2 = makeGarment(title: "B")
        let g3 = makeGarment(title: "C")

        let stats = statsController.computeStatistics(from: [g1, g2, g3])
        XCTAssertEqual(stats.totalCount, 3)
    }

    // MARK: - Status counts

    func testStatusCounts() {
        let g1 = makeGarment(title: "Kept", status: .kept)
        let g2 = makeGarment(title: "Give", status: .toGive)
        let g3 = makeGarment(title: "Sell", status: .toSell)
        let g4 = makeGarment(title: "Recycle", status: .toRecycle)
        let g5 = makeGarment(title: "Kept2", status: .kept)

        let stats = statsController.computeStatistics(from: [g1, g2, g3, g4, g5])
        XCTAssertEqual(stats.keptCount, 2)
        XCTAssertEqual(stats.toGiveCount, 1)
        XCTAssertEqual(stats.toSellCount, 1)
        XCTAssertEqual(stats.toRecycleCount, 1)
    }

    // MARK: - Never worn

    func testNeverWornCount() {
        let g1 = makeGarment(title: "Worn", wearCount: 5)
        let g2 = makeGarment(title: "NeverWorn1", wearCount: 0)
        let g3 = makeGarment(title: "NeverWorn2", wearCount: 0)

        let stats = statsController.computeStatistics(from: [g1, g2, g3])
        XCTAssertEqual(stats.neverWornCount, 2)
    }

    func testNeverWornPercentage() {
        let g1 = makeGarment(title: "Worn", wearCount: 3)
        let g2 = makeGarment(title: "NeverWorn", wearCount: 0)

        let stats = statsController.computeStatistics(from: [g1, g2])
        XCTAssertEqual(stats.neverWornPercentage, 50)
    }

    // MARK: - Average wear count

    func testAverageWearCount() {
        let g1 = makeGarment(title: "A", wearCount: 10)
        let g2 = makeGarment(title: "B", wearCount: 20)

        let stats = statsController.computeStatistics(from: [g1, g2])
        XCTAssertEqual(stats.avgWearCount, 15.0, accuracy: 0.01)
    }

    // MARK: - Category count

    func testCategoryCount() {
        let g1 = makeGarment(title: "A", category: "jean")
        let g2 = makeGarment(title: "B", category: "hoodie")
        let g3 = makeGarment(title: "C", category: "jean")
        let g4 = makeGarment(title: "D")

        let stats = statsController.computeStatistics(from: [g1, g2, g3, g4])
        XCTAssertEqual(stats.categoryCount, 2)
    }

    // MARK: - Most worn garment

    func testMostWornGarment() {
        let g1 = makeGarment(title: "Peu porte", wearCount: 2)
        let g2 = makeGarment(title: "Favori", wearCount: 50)
        let g3 = makeGarment(title: "Moyen", wearCount: 10)

        let stats = statsController.computeStatistics(from: [g1, g2, g3])
        XCTAssertEqual(stats.mostWornGarment?.title, "Favori")
    }

    func testMostWornWhenAllZeroReturnsAGarment() {
        let g1 = makeGarment(title: "A", wearCount: 0)
        let g2 = makeGarment(title: "B", wearCount: 0)

        let stats = statsController.computeStatistics(from: [g1, g2])
        XCTAssertNotNil(stats.mostWornGarment)
        XCTAssertEqual(stats.mostWornGarment?.wearCount, 0)
    }
}

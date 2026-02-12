//
//  SearchControllerTests.swift
//  My E-DressingTests
//
//  Created by Dhayan Bourguignon on 12/02/2026.
//

import XCTest
import CoreData
@testable import My_E_Dressing

final class SearchControllerTests: XCTestCase {

    private var persistenceController: PersistenceController!
    private var context: NSManagedObjectContext!
    private var searchController: SearchController!
    private var dressing: Dressing!

    @discardableResult
    private func makeGarment(
        title: String, brand: String? = nil, color: String? = nil,
        size: String? = nil, category: String? = nil, notes: String? = nil,
        status: GarmentStatus = .kept
    ) -> Garment {
        let garment = Garment(context: context)
        garment.id = UUID()
        garment.title = title
        garment.brand = brand?.nilIfEmpty
        garment.color = color?.nilIfEmpty
        garment.size = size?.nilIfEmpty
        garment.category = category?.nilIfEmpty
        garment.notes = notes?.nilIfEmpty
        garment.statusRaw = status.rawValue
        garment.createdAt = Date()
        garment.wearCount = 0
        garment.dressing = dressing
        return garment
    }

    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext

        dressing = Dressing(context: context)
        dressing.id = UUID()
        dressing.name = "Test"
        dressing.createdAt = Date()
        try? context.save()

        searchController = SearchController()
    }

    // MARK: - Empty / Whitespace query

    func testEmptyQueryReturnsEmpty() throws {
        makeGarment(title: "T-shirt")
        try context.save()
        let all = try context.fetch(Garment.fetchRequest())

        let results = searchController.search(garments: all, query: "")
        XCTAssertTrue(results.isEmpty)
    }

    func testWhitespaceQueryReturnsEmpty() throws {
        makeGarment(title: "T-shirt")
        try context.save()
        let all = try context.fetch(Garment.fetchRequest())

        let results = searchController.search(garments: all, query: "   ")
        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - Search by title

    func testSearchByTitle() throws {
        makeGarment(title: "Jean slim")
        makeGarment(title: "T-shirt blanc")
        try context.save()
        let all = try context.fetch(Garment.fetchRequest())

        let results = searchController.search(garments: all, query: "jean")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Jean slim")
    }

    // MARK: - Search by brand

    func testSearchByBrand() throws {
        makeGarment(title: "Polo", brand: "Lacoste")
        makeGarment(title: "T-shirt", brand: "Nike")
        try context.save()
        let all = try context.fetch(Garment.fetchRequest())

        let results = searchController.search(garments: all, query: "lacoste")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.brand, "Lacoste")
    }

    // MARK: - Search by color

    func testSearchByColor() throws {
        makeGarment(title: "Pull", color: "Bleu marine")
        makeGarment(title: "Veste", color: "Noir")
        try context.save()
        let all = try context.fetch(Garment.fetchRequest())

        let results = searchController.search(garments: all, query: "bleu")
        XCTAssertEqual(results.count, 1)
    }

    // MARK: - Search by size

    func testSearchBySize() throws {
        makeGarment(title: "Pantalon", size: "42")
        makeGarment(title: "Chemise", size: "M")
        try context.save()
        let all = try context.fetch(Garment.fetchRequest())

        let results = searchController.search(garments: all, query: "42")
        XCTAssertEqual(results.count, 1)
    }

    // MARK: - Search case insensitive

    func testSearchIsCaseInsensitive() throws {
        makeGarment(title: "HOODIE Oversize")
        try context.save()
        let all = try context.fetch(Garment.fetchRequest())

        let results = searchController.search(garments: all, query: "hoodie")
        XCTAssertEqual(results.count, 1)
    }

    // MARK: - Search no match

    func testSearchNoMatch() throws {
        makeGarment(title: "Jean")
        try context.save()
        let all = try context.fetch(Garment.fetchRequest())

        let results = searchController.search(garments: all, query: "chaussure")
        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - Search by notes

    func testSearchByNotes() throws {
        makeGarment(title: "Veste", notes: "Achetee en soldes a Paris")
        try context.save()
        let all = try context.fetch(Garment.fetchRequest())

        let results = searchController.search(garments: all, query: "paris")
        XCTAssertEqual(results.count, 1)
    }

    // MARK: - Multiple matches

    func testSearchReturnsMultipleMatches() throws {
        makeGarment(title: "T-shirt blanc")
        makeGarment(title: "T-shirt noir")
        makeGarment(title: "Jean slim")
        try context.save()
        let all = try context.fetch(Garment.fetchRequest())

        let results = searchController.search(garments: all, query: "t-shirt")
        XCTAssertEqual(results.count, 2)
    }
}

//
//  DressingControllerTests.swift
//  My E-DressingTests
//
//  Created by Dhayan Bourguignon on 12/02/2026.
//

import XCTest
import CoreData
@testable import My_E_Dressing

final class DressingControllerTests: XCTestCase {

    private var persistenceController: PersistenceController!
    private var context: NSManagedObjectContext!
    private var controller: DressingController!

    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        controller = DressingController(managedObjectContext: context)
    }

    // MARK: - Create

    func testCreateDressingWithValidName() throws {
        let dressing = try controller.create(name: "Mon Dressing")
        XCTAssertNotNil(dressing.id)
        XCTAssertEqual(dressing.name, "Mon Dressing")
        XCTAssertNotNil(dressing.createdAt)
    }

    func testCreateDressingWithDefaultIconAndColor() throws {
        let dressing = try controller.create(name: "Test")
        XCTAssertEqual(dressing.iconName, "cabinet.fill")
        XCTAssertEqual(dressing.colorHex, "D96C45")
    }

    func testCreateDressingWithCustomIconAndColor() throws {
        let dressing = try controller.create(name: "Sport", iconName: "figure.stand", colorHex: "A7C4A0")
        XCTAssertEqual(dressing.iconName, "figure.stand")
        XCTAssertEqual(dressing.colorHex, "A7C4A0")
    }

    func testCreateDressingWithEmptyNameThrows() throws {
        XCTAssertThrowsError(try controller.create(name: "")) { error in
            XCTAssertTrue(error is ValidationError)
        }
    }

    func testCreateDressingWithWhitespaceNameThrows() throws {
        XCTAssertThrowsError(try controller.create(name: "   ")) { error in
            XCTAssertTrue(error is ValidationError)
        }
    }

    func testCreateDressingTrimsName() throws {
        let dressing = try controller.create(name: "  Mon Dressing  ")
        XCTAssertEqual(dressing.name, "Mon Dressing")
    }

    // MARK: - Read

    func testFetchAllReturnsEmptyWhenNoDressings() throws {
        let results = try controller.fetchAll()
        XCTAssertTrue(results.isEmpty)
    }

    func testFetchAllReturnsDressingsInOrder() throws {
        try controller.create(name: "A")
        try controller.create(name: "B")
        try controller.create(name: "C")

        let results = try controller.fetchAll()
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0].name, "A")
        XCTAssertEqual(results[1].name, "B")
        XCTAssertEqual(results[2].name, "C")
    }

    func testFirstReturnsNilWhenEmpty() throws {
        let result = try controller.first()
        XCTAssertNil(result)
    }

    func testFirstReturnsDressing() throws {
        try controller.create(name: "Premier")
        let result = try controller.first()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, "Premier")
    }

    func testFindByIdReturnsCorrectDressing() throws {
        let created = try controller.create(name: "Cible")
        try controller.create(name: "Autre")

        let found = try controller.find(by: created.id!)
        XCTAssertEqual(found?.name, "Cible")
    }

    func testFindByIdReturnsNilForUnknownId() throws {
        try controller.create(name: "Test")
        let found = try controller.find(by: UUID())
        XCTAssertNil(found)
    }

    // MARK: - Update

    func testRenameDressing() throws {
        let dressing = try controller.create(name: "Ancien")
        try controller.rename(dressing, to: "Nouveau")
        XCTAssertEqual(dressing.name, "Nouveau")
    }

    func testRenameWithEmptyNameThrows() throws {
        let dressing = try controller.create(name: "Test")
        XCTAssertThrowsError(try controller.rename(dressing, to: "")) { error in
            XCTAssertTrue(error is ValidationError)
        }
    }

    func testUpdateDressingAllFields() throws {
        let dressing = try controller.create(name: "Old", iconName: "cabinet.fill", colorHex: "D96C45")
        try controller.update(dressing, name: "New", iconName: "tshirt.fill", colorHex: "8FBCBB")

        XCTAssertEqual(dressing.name, "New")
        XCTAssertEqual(dressing.iconName, "tshirt.fill")
        XCTAssertEqual(dressing.colorHex, "8FBCBB")
    }

    // MARK: - Delete

    func testDeleteDressing() throws {
        let dressing = try controller.create(name: "A supprimer")
        try controller.delete(dressing)

        let results = try controller.fetchAll()
        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - Fetch or Create Default

    func testFetchOrCreateDefaultCreatesWhenEmpty() throws {
        let dressing = try controller.fetchOrCreateDefault()
        XCTAssertNotNil(dressing)
        XCTAssertNotNil(dressing.name)
    }

    func testFetchOrCreateDefaultReturnsExistingWhenPresent() throws {
        let existing = try controller.create(name: "Existant")
        let result = try controller.fetchOrCreateDefault()
        XCTAssertEqual(result.id, existing.id)
    }
}

//
//  My_E_DressingTests.swift
//  My E-DressingTests
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import XCTest
import CoreData
import SwiftUI
@testable import My_E_Dressing

/// Quick smoke test to verify the test target compiles and Core Data stack works.
final class My_E_DressingTests: XCTestCase {

    func testPersistenceControllerInMemory() throws {
        let pc = PersistenceController(inMemory: true)
        let context = pc.container.viewContext
        XCTAssertNotNil(context)
    }

    func testAppThemeColorsExist() {
        XCTAssertNotNil(Color.themeBackground)
        XCTAssertNotNil(Color.themePrimary)
        XCTAssertNotNil(Color.themeSecondary)
        XCTAssertNotNil(Color.themeAccent)
    }

    // MARK: - Persistence

    func testPersistenceControllerContainerName() {
        let pc = PersistenceController(inMemory: true)
        XCTAssertEqual(pc.container.name, "My_E_Dressing")
    }

    func testPersistenceControllerMergePolicy() {
        let pc = PersistenceController(inMemory: true)
        let policy = pc.container.viewContext.mergePolicy as? NSMergePolicy
        XCTAssertEqual(policy, NSMergeByPropertyObjectTrumpMergePolicy as? NSMergePolicy)
    }

    func testPersistenceControllerAutoMerge() {
        let pc = PersistenceController(inMemory: true)
        XCTAssertTrue(pc.container.viewContext.automaticallyMergesChangesFromParent)
    }

    func testPersistenceInMemoryCanSaveAndFetch() throws {
        let pc = PersistenceController(inMemory: true)
        let context = pc.container.viewContext

        let dressing = Dressing(context: context)
        dressing.id = UUID()
        dressing.name = "Test"
        dressing.createdAt = Date()
        try context.save()

        let request: NSFetchRequest<Dressing> = Dressing.fetchRequest()
        let results = try context.fetch(request)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Test")
    }

    @MainActor
    func testPersistencePreviewExists() {
        let preview = PersistenceController.preview
        XCTAssertNotNil(preview.container.viewContext)
    }

    // MARK: - AppTheme Fonts

    func testSerifFontsExist() {
        XCTAssertNotNil(Font.serifLargeTitle)
        XCTAssertNotNil(Font.serifTitle)
        XCTAssertNotNil(Font.serifTitle3)
        XCTAssertNotNil(Font.serifHeadline)
    }

    func testSansFontsExist() {
        XCTAssertNotNil(Font.sansBody)
        XCTAssertNotNil(Font.sansBodyMedium)
        XCTAssertNotNil(Font.sansSubheadline)
        XCTAssertNotNil(Font.sansHeadline)
        XCTAssertNotNil(Font.sansCaption)
        XCTAssertNotNil(Font.sansCaption2)
        XCTAssertNotNil(Font.sansFootnote)
    }
}

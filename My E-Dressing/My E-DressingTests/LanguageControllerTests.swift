//
//  LanguageControllerTests.swift
//  My E-DressingTests
//
//  Created by Dhayan Bourguignon on 12/02/2026.
//

import XCTest
@testable import My_E_Dressing

@MainActor
final class LanguageControllerTests: XCTestCase {

    private var defaults: UserDefaults!
    private var controller: LanguageController!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: UUID().uuidString)!
        controller = LanguageController(defaults: defaults)
    }

    // MARK: - Default State

    func testDefaultLanguageIsSystem() {
        XCTAssertEqual(controller.selected, .system)
    }

    // MARK: - Set Language

    func testSetLanguageToFrench() {
        controller.setLanguage(.fr)
        XCTAssertEqual(controller.selected, .fr)
    }

    func testSetLanguageToEnglish() {
        controller.setLanguage(.en)
        XCTAssertEqual(controller.selected, .en)
    }

    func testSetLanguageBackToSystem() {
        controller.setLanguage(.fr)
        controller.setLanguage(.system)
        XCTAssertEqual(controller.selected, .system)
    }

    // MARK: - Persistence

    func testLanguagePersistsInUserDefaults() {
        controller.setLanguage(.fr)
        let saved = defaults.string(forKey: "appLanguage")
        XCTAssertEqual(saved, "fr")
    }

    func testLanguageRestoredFromUserDefaults() {
        defaults.set("en", forKey: "appLanguage")
        let raw = defaults.string(forKey: "appLanguage")
        let restored = raw.flatMap { AppLanguage(rawValue: $0) }
        XCTAssertEqual(restored, .en)
    }

    // MARK: - Current Locale

    func testCurrentLocaleForSystem() {
        XCTAssertEqual(controller.currentLocale, Locale.current)
    }

    func testCurrentLocaleForFrench() {
        controller.setLanguage(.fr)
        XCTAssertEqual(controller.currentLocale, Locale(identifier: "fr"))
    }

    func testCurrentLocaleForEnglish() {
        controller.setLanguage(.en)
        XCTAssertEqual(controller.currentLocale, Locale(identifier: "en"))
    }
}

//
//  ModelTests.swift
//  My E-DressingTests
//
//  Created by Dhayan Bourguignon on 12/02/2026.
//

import XCTest
import SwiftUI
@testable import My_E_Dressing

final class ModelTests: XCTestCase {

    // MARK: - Validation

    func testNonEmptyWithValidString() throws {
        let result = try Validation.nonEmpty("Hello", fieldName: "test")
        XCTAssertEqual(result, "Hello")
    }

    func testNonEmptyTrimsWhitespace() throws {
        let result = try Validation.nonEmpty("  Hello  ", fieldName: "test")
        XCTAssertEqual(result, "Hello")
    }

    func testNonEmptyThrowsOnEmptyString() {
        XCTAssertThrowsError(try Validation.nonEmpty("", fieldName: "name")) { error in
            XCTAssertTrue(error is ValidationError)
            XCTAssertNotNil((error as? ValidationError)?.message)
        }
    }

    func testNonEmptyThrowsOnWhitespaceOnly() {
        XCTAssertThrowsError(try Validation.nonEmpty("   ", fieldName: "name"))
    }

    func testNonEmptyThrowsOnNil() {
        XCTAssertThrowsError(try Validation.nonEmpty(nil, fieldName: "name"))
    }

    // MARK: - nilIfEmpty

    func testNilIfEmptyReturnsNilForEmpty() {
        XCTAssertNil("".nilIfEmpty)
    }

    func testNilIfEmptyReturnsNilForWhitespace() {
        XCTAssertNil("   ".nilIfEmpty)
    }

    func testNilIfEmptyReturnsValueForNonEmpty() {
        XCTAssertEqual("Hello".nilIfEmpty, "Hello")
    }

    func testNilIfEmptyTrimsBeforeCheck() {
        XCTAssertEqual("  Hello  ".nilIfEmpty, "Hello")
    }

    // MARK: - GarmentStatus

    func testGarmentStatusAllCases() {
        XCTAssertEqual(GarmentStatus.allCases.count, 4)
    }

    func testGarmentStatusRawValues() {
        XCTAssertEqual(GarmentStatus.kept.rawValue, 0)
        XCTAssertEqual(GarmentStatus.toGive.rawValue, 1)
        XCTAssertEqual(GarmentStatus.toSell.rawValue, 2)
        XCTAssertEqual(GarmentStatus.toRecycle.rawValue, 3)
    }

    func testGarmentStatusLabelsNotEmpty() {
        for status in GarmentStatus.allCases {
            XCTAssertFalse(status.label.isEmpty, "\(status) label should not be empty")
        }
    }

    func testGarmentStatusIconsNotEmpty() {
        for status in GarmentStatus.allCases {
            XCTAssertFalse(status.icon.isEmpty, "\(status) icon should not be empty")
        }
    }

    func testGarmentStatusFromRawValue() {
        XCTAssertEqual(GarmentStatus(rawValue: 0), .kept)
        XCTAssertEqual(GarmentStatus(rawValue: 1), .toGive)
        XCTAssertEqual(GarmentStatus(rawValue: 2), .toSell)
        XCTAssertEqual(GarmentStatus(rawValue: 3), .toRecycle)
        XCTAssertNil(GarmentStatus(rawValue: 99))
    }

    // MARK: - AppLanguage

    func testAppLanguageAllCases() {
        XCTAssertEqual(AppLanguage.allCases.count, 3)
    }

    func testAppLanguageRawValues() {
        XCTAssertEqual(AppLanguage.system.rawValue, "system")
        XCTAssertEqual(AppLanguage.en.rawValue, "en")
        XCTAssertEqual(AppLanguage.fr.rawValue, "fr")
    }

    func testAppLanguageLocale() {
        XCTAssertNil(AppLanguage.system.locale)
        XCTAssertEqual(AppLanguage.en.locale, Locale(identifier: "en"))
        XCTAssertEqual(AppLanguage.fr.locale, Locale(identifier: "fr"))
    }

    func testAppLanguageLabelsNotEmpty() {
        for lang in AppLanguage.allCases {
            XCTAssertFalse(lang.label.isEmpty, "\(lang) label should not be empty")
        }
    }

    func testAppLanguageId() {
        for lang in AppLanguage.allCases {
            XCTAssertEqual(lang.id, lang.rawValue)
        }
    }

    // MARK: - GarmentCategoryCatalog

    func testCatalogHas11Sections() {
        XCTAssertEqual(GarmentCategoryCatalog.sections.count, 11)
    }

    func testCatalogHasOver60Categories() {
        XCTAssertGreaterThan(GarmentCategoryCatalog.all.count, 60)
    }

    func testAllCategoriesHaveUniqueIds() {
        let ids = GarmentCategoryCatalog.all.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count, "All category IDs should be unique")
    }

    func testAllCategoriesHaveNonEmptyFields() {
        for category in GarmentCategoryCatalog.all {
            XCTAssertFalse(category.id.isEmpty, "Category id should not be empty")
            XCTAssertFalse(category.iconName.isEmpty, "Category iconName should not be empty")
            XCTAssertFalse(category.labelKey.isEmpty, "Category labelKey should not be empty")
        }
    }

    func testFindCategoryById() {
        let found = GarmentCategoryCatalog.find(by: "hoodie")
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.id, "hoodie")
    }

    func testFindCategoryByNilReturnsNil() {
        XCTAssertNil(GarmentCategoryCatalog.find(by: nil))
    }

    func testFindCategoryByUnknownIdReturnsNil() {
        XCTAssertNil(GarmentCategoryCatalog.find(by: "nonexistent-category"))
    }

    func testAllSectionsHaveUniqueIds() {
        let ids = GarmentCategoryCatalog.sections.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    // MARK: - SizeCatalog

    func testSizeCatalogHasAtLeast5Sections() {
        XCTAssertGreaterThanOrEqual(SizeCatalog.sections.count, 5)
    }

    func testLetterSizesContainsStandard() {
        let ids = SizeCatalog.letterSizes.map(\.id)
        XCTAssertTrue(ids.contains("S"))
        XCTAssertTrue(ids.contains("M"))
        XCTAssertTrue(ids.contains("L"))
        XCTAssertTrue(ids.contains("XL"))
    }

    func testEuSizesContainsStandard() {
        let ids = SizeCatalog.euSizes.map(\.id)
        XCTAssertTrue(ids.contains("38"))
        XCTAssertTrue(ids.contains("40"))
        XCTAssertTrue(ids.contains("42"))
    }

    func testShoeSizesRange() {
        let ids = SizeCatalog.shoeSizes.map(\.id)
        XCTAssertTrue(ids.contains("39"))
        XCTAssertTrue(ids.contains("42"))
        XCTAssertTrue(ids.contains("45"))
    }

    func testJeansSizesContainsWaist() {
        let ids = SizeCatalog.jeansSizes.map(\.id)
        XCTAssertTrue(ids.contains("W28"))
        XCTAssertTrue(ids.contains("W32"))
    }

    func testUniqueSizeIsTU() {
        XCTAssertEqual(SizeCatalog.uniqueSize.count, 1)
        XCTAssertEqual(SizeCatalog.uniqueSize.first?.id, "TU")
    }

    func testFindSizeById() {
        let found = SizeCatalog.find(by: "M")
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.display, "M")
    }

    func testFindSizeByNilReturnsNil() {
        XCTAssertNil(SizeCatalog.find(by: nil))
    }

    func testFindSizeByEmptyReturnsNil() {
        XCTAssertNil(SizeCatalog.find(by: ""))
    }

    func testFindUnknownSizeReturnsAsIs() {
        let found = SizeCatalog.find(by: "XXXL-custom")
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.id, "XXXL-custom")
        XCTAssertEqual(found?.display, "XXXL-custom")
    }

    // MARK: - DailyTipCatalog

    func testDailyTipCatalogHas20Tips() {
        XCTAssertEqual(DailyTipCatalog.tips.count, 20)
    }

    func testTodayTipIsNotEmpty() {
        XCTAssertFalse(DailyTipCatalog.todayTip.isEmpty)
    }

    func testTodayDateStringIsNotEmpty() {
        XCTAssertFalse(DailyTipCatalog.todayDateString.isEmpty)
    }

    func testTodayTipIsDeterministic() {
        let tip1 = DailyTipCatalog.todayTip
        let tip2 = DailyTipCatalog.todayTip
        XCTAssertEqual(tip1, tip2, "Same day should produce the same tip")
    }

    func testAllTipsAreNonEmpty() {
        for tip in DailyTipCatalog.tips {
            XCTAssertFalse(tip.isEmpty, "Each tip should be non-empty")
        }
    }

    // MARK: - GarmentCategory Struct

    func testGarmentCategoryLabelReturnsNonEmpty() {
        let category = GarmentCategoryCatalog.hoodie
        XCTAssertFalse(category.label.isEmpty)
    }

    func testCategorySectionTitleReturnsNonEmpty() {
        for section in GarmentCategoryCatalog.sections {
            XCTAssertFalse(section.title.isEmpty, "Section \(section.id) title should be non-empty")
            XCTAssertFalse(section.categories.isEmpty, "Section \(section.id) should have categories")
        }
    }

    func testCategoryEquality() {
        let cat1 = GarmentCategoryCatalog.hoodie
        let cat2 = GarmentCategoryCatalog.hoodie
        let cat3 = GarmentCategoryCatalog.jean
        XCTAssertEqual(cat1, cat2)
        XCTAssertNotEqual(cat1, cat3)
    }

    func testCategoryIdentifiable() {
        let cat = GarmentCategoryCatalog.sneaker
        XCTAssertEqual(cat.id, "sneaker")
    }

    // MARK: - SizeCatalog Advanced

    func testAllSizesReturnsAllBuiltInSizes() {
        let allSizes = SizeCatalog.allSizes
        XCTAssertGreaterThan(allSizes.count, 30)
    }

    func testSizeOptionEquality() {
        let s1 = SizeOption(id: "M", display: "M")
        let s2 = SizeOption(id: "M", display: "M")
        let s3 = SizeOption(id: "L", display: "L")
        XCTAssertEqual(s1, s2)
        XCTAssertNotEqual(s1, s3)
    }

    func testSizeSectionsHaveTitles() {
        for section in SizeCatalog.sections {
            XCTAssertFalse(section.id.isEmpty)
            XCTAssertFalse(section.titleKey.isEmpty)
            XCTAssertFalse(section.sizes.isEmpty, "Section \(section.id) should have sizes")
        }
    }

    func testAddCustomSizeAndFind() {
        SizeCatalog.addCustomSize("XXXXXL", toSection: "custom")
        let found = SizeCatalog.find(by: "XXXXXL")
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.display, "XXXXXL")
    }

    func testAddCustomSizeIgnoresEmpty() {
        let countBefore = SizeCatalog.allSizes.count
        SizeCatalog.addCustomSize("   ", toSection: "custom")
        let countAfter = SizeCatalog.allSizes.count
        XCTAssertEqual(countBefore, countAfter)
    }

    func testAddCustomSizeIgnoresBuiltIn() {
        let countBefore = SizeCatalog.allSizes.count
        SizeCatalog.addCustomSize("M", toSection: "letter")
        let countAfter = SizeCatalog.allSizes.count
        XCTAssertEqual(countBefore, countAfter)
    }

    // MARK: - DressingIcon

    func testDressingIconAllNotEmpty() {
        XCTAssertGreaterThan(DressingIcon.all.count, 10)
        for icon in DressingIcon.all {
            XCTAssertFalse(icon.isEmpty)
        }
    }

    func testDressingIconDefault() {
        XCTAssertEqual(DressingIcon.defaultIcon, "cabinet.fill")
        XCTAssertTrue(DressingIcon.all.contains(DressingIcon.defaultIcon))
    }

    // MARK: - DressingColor

    func testDressingColorAllNotEmpty() {
        XCTAssertGreaterThan(DressingColor.all.count, 5)
        for color in DressingColor.all {
            XCTAssertFalse(color.hex.isEmpty)
            XCTAssertFalse(color.name.isEmpty)
        }
    }

    func testDressingColorDefault() {
        XCTAssertEqual(DressingColor.defaultHex, "D96C45")
        XCTAssertTrue(DressingColor.all.contains(where: { $0.hex == DressingColor.defaultHex }))
    }

    // MARK: - Color(hex:) Initializer

    func testColorHex6Digits() {
        let color = Color(hex: "FF0000")
        XCTAssertNotNil(color)
    }

    func testColorHex3Digits() {
        let color = Color(hex: "F00")
        XCTAssertNotNil(color)
    }

    func testColorHex8Digits() {
        let color = Color(hex: "80FF0000")
        XCTAssertNotNil(color)
    }

    func testColorHexWithHashPrefix() {
        let color = Color(hex: "#D96C45")
        XCTAssertNotNil(color)
    }

    func testColorHexInvalidFallback() {
        let color = Color(hex: "X")
        XCTAssertNotNil(color)
    }

    // MARK: - Validation Error Message

    func testValidationErrorHasMessage() {
        let error = ValidationError(message: "Test error")
        XCTAssertEqual(error.message, "Test error")
    }
}

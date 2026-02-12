//
//  MediaStoreTests.swift
//  My E-DressingTests
//
//  Created by Dhayan Bourguignon on 12/02/2026.
//

import XCTest
import UIKit
@testable import My_E_Dressing

final class MediaStoreTests: XCTestCase {

    private var savedPaths: [String] = []

    private func makeTestImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image { ctx in
            UIColor.blue.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
    }

    override func tearDownWithError() throws {
        // Clean up saved test images
        for path in savedPaths {
            MediaStore.shared.delete(at: path)
        }
        savedPaths.removeAll()
    }

    // MARK: - Save

    func testSaveJPEGReturnsRelativeFilename() throws {
        let path = try MediaStore.shared.saveJPEG(makeTestImage())
        savedPaths.append(path)

        XCTAssertFalse(path.hasPrefix("/"), "Path should be relative, not absolute")
        XCTAssertTrue(path.hasPrefix("media_"), "Path should start with 'media_'")
        XCTAssertTrue(path.hasSuffix(".jpg"), "Path should end with '.jpg'")
    }

    func testSaveJPEGCreatesFile() throws {
        let filename = try MediaStore.shared.saveJPEG(makeTestImage())
        savedPaths.append(filename)

        let absolutePath = MediaStore.shared.absolutePath(for: filename)
        XCTAssertTrue(FileManager.default.fileExists(atPath: absolutePath))
    }

    // MARK: - Load

    func testLoadImageFromRelativePath() throws {
        let filename = try MediaStore.shared.saveJPEG(makeTestImage())
        savedPaths.append(filename)

        let loaded = MediaStore.shared.loadImage(at: filename)
        XCTAssertNotNil(loaded)
    }

    func testLoadImageFromNonExistentPathReturnsNil() {
        let loaded = MediaStore.shared.loadImage(at: "nonexistent_image.jpg")
        XCTAssertNil(loaded)
    }

    // MARK: - Delete

    func testDeleteRemovesFile() throws {
        let filename = try MediaStore.shared.saveJPEG(makeTestImage())
        let absolutePath = MediaStore.shared.absolutePath(for: filename)

        XCTAssertTrue(FileManager.default.fileExists(atPath: absolutePath))

        MediaStore.shared.delete(at: filename)
        XCTAssertFalse(FileManager.default.fileExists(atPath: absolutePath))
    }

    func testDeleteNonExistentFileDoesNotCrash() {
        // Should not throw or crash
        MediaStore.shared.delete(at: "nonexistent_file.jpg")
    }

    // MARK: - Absolute Path Resolution

    func testAbsolutePathForRelativeFilename() throws {
        let filename = "media_test123.jpg"
        let resolved = MediaStore.shared.absolutePath(for: filename)

        XCTAssertTrue(resolved.hasPrefix("/"), "Resolved path should be absolute")
        XCTAssertTrue(resolved.hasSuffix(filename), "Resolved path should end with filename")
    }

    func testAbsolutePathForAbsolutePathWithExistingFile() throws {
        let filename = try MediaStore.shared.saveJPEG(makeTestImage())
        savedPaths.append(filename)

        let absolutePath = MediaStore.shared.absolutePath(for: filename)

        // If we pass an absolute path that exists, it should return it as-is
        let resolved = MediaStore.shared.absolutePath(for: absolutePath)
        XCTAssertEqual(resolved, absolutePath)
    }

    func testAbsolutePathForLegacyAbsolutePathExtractsFilename() {
        // Simulate a legacy absolute path with a non-existent container
        let legacyPath = "/old/container/path/media_legacy123.jpg"
        let resolved = MediaStore.shared.absolutePath(for: legacyPath)

        // Should extract filename and prepend current Documents directory
        XCTAssertTrue(resolved.hasSuffix("media_legacy123.jpg"))
        XCTAssertNotEqual(resolved, legacyPath)
    }

    // MARK: - Multiple saves produce unique filenames

    func testMultipleSavesProduceUniqueFilenames() throws {
        let path1 = try MediaStore.shared.saveJPEG(makeTestImage())
        let path2 = try MediaStore.shared.saveJPEG(makeTestImage())
        savedPaths.append(contentsOf: [path1, path2])

        XCTAssertNotEqual(path1, path2)
    }
}

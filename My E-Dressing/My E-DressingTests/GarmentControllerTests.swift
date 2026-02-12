//
//  GarmentControllerTests.swift
//  My E-DressingTests
//
//  Created by Dhayan Bourguignon on 12/02/2026.
//

import XCTest
import CoreData
import UIKit
@testable import My_E_Dressing

final class GarmentControllerTests: XCTestCase {

    private var persistenceController: PersistenceController!
    private var context: NSManagedObjectContext!
    private var garmentController: GarmentController!
    private var dressing: Dressing!

    private func makeTestImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
    }

    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        garmentController = GarmentController(managedObjectContext: context)

        dressing = Dressing(context: context)
        dressing.id = UUID()
        dressing.name = "Test Dressing"
        dressing.createdAt = Date()
        try? context.save()
    }

    // MARK: - Create

    func testCreateGarmentWithValidData() throws {
        let garment = try garmentController.create(
            in: dressing,
            title: "T-shirt",
            brand: "Nike",
            color: "Blanc",
            size: "M",
            category: "tshirt-col-rond",
            notes: "Super",
            status: .kept,
            wearCount: 5,
            photos: [makeTestImage()]
        )

        XCTAssertNotNil(garment.id)
        XCTAssertEqual(garment.title, "T-shirt")
        XCTAssertEqual(garment.brand, "Nike")
        XCTAssertEqual(garment.color, "Blanc")
        XCTAssertEqual(garment.size, "M")
        XCTAssertEqual(garment.category, "tshirt-col-rond")
        XCTAssertEqual(garment.notes, "Super")
        XCTAssertEqual(garment.statusRaw, GarmentStatus.kept.rawValue)
        XCTAssertEqual(garment.wearCount, 5)
        XCTAssertEqual(garment.dressing, dressing)
    }

    func testCreateGarmentWithEmptyTitleThrows() throws {
        XCTAssertThrowsError(try garmentController.create(
            in: dressing, title: "", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0, photos: [makeTestImage()]
        )) { error in
            XCTAssertTrue(error is ValidationError)
        }
    }

    func testCreateGarmentWithNoPhotosThrows() throws {
        XCTAssertThrowsError(try garmentController.create(
            in: dressing, title: "Test", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0, photos: []
        )) { error in
            XCTAssertTrue(error is ValidationError)
        }
    }

    func testCreateGarmentNilIfEmptyForOptionalFields() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Test", brand: "", color: "  ",
            size: nil, category: "", notes: "  ",
            status: .kept, wearCount: 0, photos: [makeTestImage()]
        )

        XCTAssertNil(garment.brand)
        XCTAssertNil(garment.color)
        XCTAssertNil(garment.size)
        XCTAssertNil(garment.category)
        XCTAssertNil(garment.notes)
    }

    func testCreateGarmentAttachesPhotos() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Multi", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0,
            photos: [makeTestImage(), makeTestImage(), makeTestImage()]
        )

        XCTAssertEqual(garment.photoSet.count, 3)
    }

    // MARK: - Update

    func testUpdateGarmentMetadata() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Old", brand: "Old Brand", color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0, photos: [makeTestImage()]
        )

        try garmentController.update(
            garment, title: "New", brand: "New Brand", color: "Rouge",
            size: "L", category: "hoodie", notes: "Updated",
            wearCount: 10, status: .toGive
        )

        XCTAssertEqual(garment.title, "New")
        XCTAssertEqual(garment.brand, "New Brand")
        XCTAssertEqual(garment.color, "Rouge")
        XCTAssertEqual(garment.size, "L")
        XCTAssertEqual(garment.category, "hoodie")
        XCTAssertEqual(garment.notes, "Updated")
        XCTAssertEqual(garment.wearCount, 10)
        XCTAssertEqual(garment.statusRaw, GarmentStatus.toGive.rawValue)
    }

    func testUpdateWithEmptyTitleThrows() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Valid", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0, photos: [makeTestImage()]
        )

        XCTAssertThrowsError(try garmentController.update(
            garment, title: "", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            wearCount: 0, status: .kept
        ))
    }

    // MARK: - Status & Wear Count

    func testChangeStatus() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Test", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0, photos: [makeTestImage()]
        )

        try garmentController.changeStatus(garment, to: .toSell)
        XCTAssertEqual(garment.statusRaw, GarmentStatus.toSell.rawValue)
    }

    func testIncrementWearCount() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Test", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0, photos: [makeTestImage()]
        )

        try garmentController.incrementWearCount(garment)
        XCTAssertEqual(garment.wearCount, 1)

        try garmentController.incrementWearCount(garment)
        XCTAssertEqual(garment.wearCount, 2)
    }

    // MARK: - Photo Operations

    func testAddPhotosToGarment() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Test", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0, photos: [makeTestImage()]
        )

        XCTAssertEqual(garment.photoSet.count, 1)

        let newPhotos = try garmentController.addPhotos([makeTestImage(), makeTestImage()], to: garment)
        XCTAssertEqual(newPhotos.count, 2)
        XCTAssertEqual(garment.photoSet.count, 3)
    }

    func testPhotoOrderIndex() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Test", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0,
            photos: [makeTestImage(), makeTestImage()]
        )

        let ordered = garment.orderedPhotos
        XCTAssertEqual(ordered[0].orderIndex, 0)
        XCTAssertEqual(ordered[1].orderIndex, 1)
    }

    // MARK: - Delete

    func testDeleteGarment() throws {
        let garment = try garmentController.create(
            in: dressing, title: "A supprimer", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0, photos: [makeTestImage()]
        )

        try garmentController.delete(garment)

        let request: NSFetchRequest<Garment> = Garment.fetchRequest()
        let count = try context.count(for: request)
        XCTAssertEqual(count, 0)
    }

    // MARK: - Validate Photos

    func testValidateHasAtLeastOnePhotoSucceeds() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Test", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0, photos: [makeTestImage()]
        )

        XCTAssertNoThrow(try garmentController.validateHasAtLeastOnePhoto(garment))
    }

    func testValidateHasAtLeastOnePhotoFailsWhenEmpty() throws {
        let garment = Garment(context: context)
        garment.id = UUID()
        garment.title = "Empty"

        XCTAssertThrowsError(try garmentController.validateHasAtLeastOnePhoto(garment)) { error in
            XCTAssertTrue(error is ValidationError)
        }
    }

    // MARK: - Remove Photos

    func testRemovePhotosFromGarment() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Test", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0,
            photos: [makeTestImage(), makeTestImage(), makeTestImage()]
        )

        XCTAssertEqual(garment.photoSet.count, 3)

        let photoToRemove = garment.orderedPhotos.first!
        try garmentController.removePhotos([photoToRemove], from: garment)
        XCTAssertEqual(garment.photoSet.count, 2)
    }

    // MARK: - Reorder Photos

    func testReorderPhotos() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Test", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0,
            photos: [makeTestImage(), makeTestImage(), makeTestImage()]
        )

        var photos = garment.orderedPhotos
        XCTAssertEqual(photos.count, 3)

        let reversed = Array(photos.reversed())
        try garmentController.reorderPhotos(reversed)

        photos = garment.orderedPhotos
        XCTAssertEqual(photos[0].orderIndex, 0)
        XCTAssertEqual(photos[1].orderIndex, 1)
        XCTAssertEqual(photos[2].orderIndex, 2)
    }

    // MARK: - Delete cleans up photos

    func testDeleteGarmentAlsoDeletesPhotos() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Test", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0,
            photos: [makeTestImage(), makeTestImage()]
        )

        XCTAssertEqual(garment.photoSet.count, 2)
        try garmentController.delete(garment)

        let photoRequest: NSFetchRequest<GarmentPhoto> = GarmentPhoto.fetchRequest()
        let photoCount = try context.count(for: photoRequest)
        XCTAssertEqual(photoCount, 0)
    }

    // MARK: - Change all statuses

    func testChangeStatusToGive() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Test", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0, photos: [makeTestImage()]
        )

        try garmentController.changeStatus(garment, to: .toGive)
        XCTAssertEqual(garment.statusRaw, GarmentStatus.toGive.rawValue)
    }

    func testChangeStatusToRecycle() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Test", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0, photos: [makeTestImage()]
        )

        try garmentController.changeStatus(garment, to: .toRecycle)
        XCTAssertEqual(garment.statusRaw, GarmentStatus.toRecycle.rawValue)
    }

    // MARK: - Garment Photo Extensions

    func testPhotoSetEmptyByDefault() {
        let garment = Garment(context: context)
        garment.id = UUID()
        garment.title = "Empty"
        XCTAssertTrue(garment.photoSet.isEmpty)
    }

    func testOrderedPhotosEmpty() {
        let garment = Garment(context: context)
        garment.id = UUID()
        garment.title = "Empty"
        XCTAssertTrue(garment.orderedPhotos.isEmpty)
    }

    func testPrimaryPhotoPathNilWhenNoPhotos() {
        let garment = Garment(context: context)
        garment.id = UUID()
        garment.title = "Empty"
        XCTAssertNil(garment.primaryPhotoPath)
    }

    func testPrimaryImageNilWhenNoPhotos() {
        let garment = Garment(context: context)
        garment.id = UUID()
        garment.title = "Empty"
        XCTAssertNil(garment.primaryImage)
    }

    func testPrimaryPhotoPathReturnsFirst() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Test", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0,
            photos: [makeTestImage(), makeTestImage()]
        )

        XCTAssertNotNil(garment.primaryPhotoPath)
    }

    func testAllLoadedImagesEmptyWhenNoPhotos() {
        let garment = Garment(context: context)
        garment.id = UUID()
        garment.title = "Empty"
        XCTAssertTrue(garment.allLoadedImages.isEmpty)
    }

    func testAllLoadedImagesReturnsImages() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Test", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .kept, wearCount: 0,
            photos: [makeTestImage(), makeTestImage()]
        )

        let loaded = garment.allLoadedImages
        XCTAssertEqual(loaded.count, 2)
    }

    // MARK: - Create with all statuses

    func testCreateGarmentWithStatusToSell() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Sell", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .toSell, wearCount: 0, photos: [makeTestImage()]
        )
        XCTAssertEqual(garment.statusRaw, GarmentStatus.toSell.rawValue)
    }

    func testCreateGarmentWithStatusToRecycle() throws {
        let garment = try garmentController.create(
            in: dressing, title: "Recycle", brand: nil, color: nil,
            size: nil, category: nil, notes: nil,
            status: .toRecycle, wearCount: 0, photos: [makeTestImage()]
        )
        XCTAssertEqual(garment.statusRaw, GarmentStatus.toRecycle.rawValue)
    }
}

//
//  MediaStore.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import UIKit

/// Handles saving, loading and deleting garment images in the Documents directory.
///
/// Paths stored in Core Data are **relative filenames** (e.g. `media_UUID.jpg`).
/// The full path is rebuilt at runtime via `absolutePath(for:)` so it survives
/// sandbox container changes across app launches / updates.
final class MediaStore {
    static let shared = MediaStore()
    private init() {}

    private var documentsDirectory: URL {
        // swiftlint:disable:next force_try
        try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }

    /// Saves the image as JPEG and returns the **relative filename** (not the absolute path).
    func saveJPEG(_ image: UIImage, quality: CGFloat = 0.9) throws -> String {
        guard let data = image.jpegData(compressionQuality: quality) else {
            throw ValidationError(message: "Invalid image data")
        }
        let filename = "media_\(UUID().uuidString).jpg"
        let url = documentsDirectory.appendingPathComponent(filename)
        try data.write(to: url, options: .atomic)
        return filename
    }

    /// Loads an image from either a relative filename or a legacy absolute path.
    func loadImage(at path: String) -> UIImage? {
        let resolvedPath = absolutePath(for: path)
        return UIImage(contentsOfFile: resolvedPath)
    }

    /// Deletes the image file for a relative filename or legacy absolute path.
    func delete(at path: String) {
        let resolvedPath = absolutePath(for: path)
        try? FileManager.default.removeItem(atPath: resolvedPath)
    }

    /// Converts a stored path to an absolute path.
    /// - If the path is already absolute **and** the file exists, returns it as-is (legacy support).
    /// - If the path is just a filename, prepends the current Documents directory.
    /// - If the path is an absolute legacy path whose file no longer exists,
    ///   extracts the filename and looks in the current Documents directory.
    func absolutePath(for storedPath: String) -> String {
        // Case 1: It's a relative filename (no "/" prefix)
        if !storedPath.hasPrefix("/") {
            return documentsDirectory.appendingPathComponent(storedPath).path
        }

        // Case 2: Absolute path that still works (unlikely after container change, but handle it)
        if FileManager.default.fileExists(atPath: storedPath) {
            return storedPath
        }

        // Case 3: Legacy absolute path — extract just the filename and resolve it
        let filename = (storedPath as NSString).lastPathComponent
        return documentsDirectory.appendingPathComponent(filename).path
    }
}

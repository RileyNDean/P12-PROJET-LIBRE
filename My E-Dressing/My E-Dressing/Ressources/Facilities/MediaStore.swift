//
//  MediaStore.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import UIKit

/// Handles saving, loading and deleting garment images in the Documents directory.
final class MediaStore {
    static let shared = MediaStore()
    private init() {}

    func saveJPEG(_ image: UIImage, quality: CGFloat = 0.9) throws -> String {
        guard let data = image.jpegData(compressionQuality: quality) else {
            throw ValidationError(message: "Invalid image data")
        }
        let url = try fileURL(for: UUID().uuidString)
        try data.write(to: url, options: .atomic)
        return url.path
    }

    func loadImage(at absolutePath: String) -> UIImage? {
        UIImage(contentsOfFile: absolutePath)
    }

    func delete(at absolutePath: String) {
        try? FileManager.default.removeItem(atPath: absolutePath)
    }

    private func fileURL(for id: String) throws -> URL {
        let dir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return dir.appendingPathComponent("media_\(id).jpg")
    }
}

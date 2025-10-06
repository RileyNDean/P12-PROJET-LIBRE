//
//  Validation.swift
//  My E-Dressing
//
//  Created by Dhayan Bourguignon on 06/10/2025.
//

import Foundation

/// Lightweight input validation helpers used by controllers.
struct ValidationError: Error, LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

enum Validation {
    /// Returns a trimmed non-empty string or throws.
    /// - Parameters:
    ///   - value: optional input
    ///   - field: field name for error messages
    static func nonEmpty(_ value: String?, field: String) throws -> String {
        let trimmedValue = (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else {
            throw ValidationError(message: "\(field) is required")
        }
        return trimmedValue
    }
}

extension String {
    /// Returns nil if the trimmed string is empty. Useful to store optionals.
    var nilIfEmpty: String? {
        let trimmedString = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedString.isEmpty ? nil : trimmedString
    }
}

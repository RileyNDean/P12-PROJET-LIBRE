//
// Validation helpers to ensure non-empty input and optional storage.
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
    ///   - fieldName: field name for error messages
    static func nonEmpty(_ value: String?, fieldName: String) throws -> String {
        let trimmedValue = (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else {
            throw ValidationError(message: "\(fieldName) is required")
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

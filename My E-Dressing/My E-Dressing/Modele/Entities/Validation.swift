import Foundation

/// A custom error carrying a user-facing message for form validation failures.
struct ValidationError: Error, LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

/// Utility methods for validating user input before persisting to Core Data.
enum Validation {
    /// Returns a trimmed non-empty string, or throws a `ValidationError` if blank.
    static func nonEmpty(_ value: String?, fieldName: String) throws -> String {
        let trimmedValue = (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else {
            throw ValidationError(message: "\(fieldName) is required")
        }
        return trimmedValue
    }
}

extension String {
    var nilIfEmpty: String? {
        let trimmedString = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedString.isEmpty ? nil : trimmedString
    }
}

import Foundation

struct ValidationError: Error, LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

enum Validation {
    /// Returns a trimmed non-empty string, or throws if blank.
    static func nonEmpty(_ value: String?, fieldName: String) throws -> String {
        let trimmedValue = (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else {
            throw ValidationError(message: "\(fieldName) is required")
        }
        return trimmedValue
    }
}

extension String {
    /// Returns nil when the trimmed string is empty, useful for optional Core Data fields.
    var nilIfEmpty: String? {
        let trimmedString = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedString.isEmpty ? nil : trimmedString
    }
}

import Foundation

/// Browser-readable copy of the current filter policy.
///
/// The macOS app writes this to the shared app-group container. Browser native
/// hosts can read it without depending on Network Extension internals.
struct BrowserPolicySnapshot: Codable {
    static let currentSchemaVersion = 1

    var schemaVersion: Int
    var policyVersion: String
    var generatedAtUnixSeconds: TimeInterval
    var loadedFilterRules: LoadedFilterRules

    init(
        schemaVersion: Int = Self.currentSchemaVersion,
        policyVersion: String,
        generatedAtUnixSeconds: TimeInterval,
        loadedFilterRules: LoadedFilterRules
    ) {
        self.schemaVersion = schemaVersion
        self.policyVersion = policyVersion
        self.generatedAtUnixSeconds = generatedAtUnixSeconds
        self.loadedFilterRules = loadedFilterRules
    }
}

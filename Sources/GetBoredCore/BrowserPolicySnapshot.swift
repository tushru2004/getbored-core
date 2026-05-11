import Foundation

/// Browser-readable copy of the current filter policy.
///
/// The macOS app writes this to the shared app-group container. Browser native
/// hosts can read it without depending on Network Extension internals.
public struct BrowserPolicySnapshot: Codable {
    public static let currentSchemaVersion = 1

    public var schemaVersion: Int
    public var policyVersion: String
    public var generatedAtUnixSeconds: TimeInterval
    public var loadedFilterRules: LoadedFilterRules

    public init(
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

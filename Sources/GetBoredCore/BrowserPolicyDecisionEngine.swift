import Foundation

/// Turns browser requests plus a loaded policy snapshot into filter decisions.
///
/// The native messaging host should stay mostly transport code: read one JSON
/// request from Chrome, load `BrowserPolicySnapshot.json`, call this engine,
/// and write one JSON response back.
public enum BrowserPolicyDecisionEngine {
    public enum DecisionError: Error, Equatable {
        case unsupportedSchemaVersion(Int)
    }

    public static func decide(
        request: BrowserFilterDecisionRequest,
        snapshotData: Data,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> BrowserFilterDecisionResponse {
        let snapshot = try decoder.decode(BrowserPolicySnapshot.self, from: snapshotData)
        return try decide(request: request, snapshot: snapshot)
    }

    public static func decide(
        request: BrowserFilterDecisionRequest,
        snapshot: BrowserPolicySnapshot
    ) throws -> BrowserFilterDecisionResponse {
        guard snapshot.schemaVersion == BrowserPolicySnapshot.currentSchemaVersion else {
            throw DecisionError.unsupportedSchemaVersion(snapshot.schemaVersion)
        }

        let decision = DecisionCore.browserDecision(for: request, using: snapshot.loadedFilterRules)
        return BrowserFilterDecisionResponse(
            shouldBlock: decision.shouldBlock,
            reason: decision.reason,
            policyVersion: snapshot.policyVersion
        )
    }
}

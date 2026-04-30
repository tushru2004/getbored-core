import Foundation

/// Testable core for the future browser native messaging host.
///
/// Chrome native messaging adds process framing around stdin/stdout. This type
/// handles only the policy part: decode the request JSON, load the snapshot
/// file, run the decision engine, and encode the response JSON.
public enum BrowserNativeHostRunner {
    public static func handleRequest(
        requestData: Data,
        snapshotURL: URL,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> Data {
        let request = try decoder.decode(BrowserFilterDecisionRequest.self, from: requestData)
        let snapshotData = try Data(contentsOf: snapshotURL)
        let response = try BrowserPolicyDecisionEngine.decide(
            request: request,
            snapshotData: snapshotData,
            decoder: decoder
        )
        return try encoder.encode(response)
    }
}

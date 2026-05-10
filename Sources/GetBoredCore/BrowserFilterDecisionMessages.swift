import Foundation

/// Request shape used by browser integrations when asking native code for a
/// filtering decision. Chrome will send this to the native messaging host.
public struct BrowserFilterDecisionRequest: Codable, Equatable {
    public var url: String
    public var topLevelURL: String?
    public var tabIdentifier: Int?

    public init(url: String, topLevelURL: String? = nil, tabIdentifier: Int? = nil) {
        self.url = url
        self.topLevelURL = topLevelURL
        self.tabIdentifier = tabIdentifier
    }
}

/// Response shape returned to the browser integration.
public struct BrowserFilterDecisionResponse: Codable, Equatable {
    public var shouldBlock: Bool
    public var reason: String
    public var policyVersion: String?

    public init(shouldBlock: Bool, reason: String, policyVersion: String? = nil) {
        self.shouldBlock = shouldBlock
        self.reason = reason
        self.policyVersion = policyVersion
    }
}

extension DecisionCore {
    public static func browserDecision(
        for request: BrowserFilterDecisionRequest,
        using loadedFilterRules: LoadedFilterRules
    ) -> BrowserFilterDecisionResponse {
        let shouldBlock = shouldBlock(request.url, using: loadedFilterRules)
        let reason = shouldBlock ? "Blocked by loaded filter rules" : "Allowed by loaded filter rules"
        return BrowserFilterDecisionResponse(shouldBlock: shouldBlock, reason: reason)
    }
}

import Foundation

/// Request shape used by browser integrations when asking native code for a
/// filtering decision. Chrome will send this to the native messaging host.
struct BrowserFilterDecisionRequest: Codable, Equatable {
    var url: String
    var topLevelURL: String?
    var tabIdentifier: Int?

    init(url: String, topLevelURL: String? = nil, tabIdentifier: Int? = nil) {
        self.url = url
        self.topLevelURL = topLevelURL
        self.tabIdentifier = tabIdentifier
    }
}

/// Response shape returned to the browser integration.
struct BrowserFilterDecisionResponse: Codable, Equatable {
    var shouldBlock: Bool
    var reason: String

    init(shouldBlock: Bool, reason: String) {
        self.shouldBlock = shouldBlock
        self.reason = reason
    }
}

extension DecisionCore {
    static func browserDecision(
        for request: BrowserFilterDecisionRequest,
        using loadedFilterRules: LoadedFilterRules
    ) -> BrowserFilterDecisionResponse {
        let shouldBlock = shouldBlock(request.url, using: loadedFilterRules)
        let reason = shouldBlock ? "Blocked by loaded filter rules" : "Allowed by loaded filter rules"
        return BrowserFilterDecisionResponse(shouldBlock: shouldBlock, reason: reason)
    }
}

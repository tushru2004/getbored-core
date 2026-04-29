import Foundation

struct PolicySnapshot {
    var siteRules: [SiteRule] = []
    var filterMode: String = "blockSpecific"
    var exceptions: [String] = []
    var allowedAppBundleIDs: [String] = []
}

/// Pure policy-decision helpers shared by native filters and browser integrations.
///
/// `DecisionCore` does not read app state, UserDefaults, Network Extension config,
/// or browser APIs. Callers pass already-loaded policy data in, and this type
/// answers deterministic matching questions.
///
/// Example domain rule behavior:
/// - rule `github.com` matches `github.com`
/// - rule `github.com` matches `www.github.com`
/// - rule `github.com` matches `https://www.github.com/tushru2004/GetBored`
/// - rule `github.com` does not match `github.com.evil.example`
enum DecisionCore {
    static func host(_ host: String, matchesRule rule: String) -> Bool {
        let normalizedHost = normalizeHost(host)
        let normalizedRule = normalizeHost(rule)

        guard !normalizedHost.isEmpty, !normalizedRule.isEmpty else {
            return false
        }

        return normalizedHost == normalizedRule || normalizedHost.hasSuffix("." + normalizedRule)
    }

    private static func normalizeHost(_ input: String) -> String {
        var value = input.lowercased()

        if let range = value.range(of: "://") {
            value = String(value[range.upperBound...])
        }
        if let slash = value.firstIndex(of: "/") {
            value = String(value[..<slash])
        }
        if let colon = value.firstIndex(of: ":") {
            value = String(value[..<colon])
        }
        if let question = value.firstIndex(of: "?") {
            value = String(value[..<question])
        }

        return value
    }
}

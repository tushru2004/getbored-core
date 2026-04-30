import Foundation

/// Rules already loaded from platform-specific storage.
///
/// macOS may load these from Network Extension vendor config, iOS may load
/// them from app-group defaults, and browser extensions may load them from a
/// native messaging response. `DecisionCore` only sees this normalized value.
struct LoadedFilterRules {
    var siteRules: [SiteRule] = []
    var filterMode: FilterMode = .blockSpecific
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
    static func shouldBlock(_ url: String, using loadedRules: LoadedFilterRules) -> Bool {
        if matchesException(url, using: loadedRules) {
            return false
        }

        let matchedSiteRule = matchesSiteRule(url, using: loadedRules)

        switch loadedRules.filterMode {
        case .whiteList:
            return !matchedSiteRule
        case .blockSpecific:
            return matchedSiteRule
        }
    }

    static func matchesAllowedApp(_ bundleID: String, using loadedRules: LoadedFilterRules) -> Bool {
        let normalizedBundleID = bundleID.lowercased()

        return loadedRules.allowedAppBundleIDs.contains { stored in
            let allowed = stored.lowercased()
            return normalizedBundleID == allowed || normalizedBundleID.hasSuffix("." + allowed)
        }
    }

    static func matchesException(_ url: String, using loadedRules: LoadedFilterRules) -> Bool {
        let normalizedURL = normalizeURLPrefix(url)

        return loadedRules.exceptions.contains { exception in
            let pattern = normalizeURLPrefix(exception)
            guard !pattern.isEmpty else { return false }

            // Exceptions are path prefixes, but only across real URL boundaries.
            // `github.com/project` matches `github.com/project/issues`, not
            // `github.com/projectEvil`.
            return normalizedURL == pattern
                || normalizedURL.hasPrefix(pattern + "/")
                || normalizedURL.hasPrefix(pattern + "?")
                || normalizedURL.hasPrefix(pattern + "#")
        }
    }

    static func matchesSiteRule(_ url: String, using loadedRules: LoadedFilterRules) -> Bool {
        loadedRules.siteRules.contains { rule in
            matchesHostRule(url, rule: rule.url)
        }
    }

    static func matchesHostRule(_ hostOrURL: String, rule: String) -> Bool {
        let normalizedHost = normalizeHost(hostOrURL)
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

    private static func normalizeURLPrefix(_ input: String) -> String {
        var value = input.lowercased()

        // Exception entries and browser URLs may differ by scheme or common
        // `www.` prefix; normalize those before applying boundary matching.
        if let range = value.range(of: "://") {
            value = String(value[range.upperBound...])
        }
        if value.hasPrefix("www.") {
            value = String(value.dropFirst(4))
        }

        return value
    }
}

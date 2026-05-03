//
//  BrowserDecisionCore.swift
//  GetBored
//
//  Shared rule-based browser decision logic for browser extensions and
//  native hosts. This mirrors the macOS MacGateKeeper host semantics without
//  depending on NetworkExtension.
//

import Foundation

public struct BrowserPolicySnapshot: Codable, Equatable {
    public var policyVersion: String
    public var mode: String
    public var siteRules: [BrowserSiteRule]
    public var exceptions: [String]
    public var supportDomains: [String: [String]]

    public init(
        policyVersion: String,
        mode: String,
        siteRules: [BrowserSiteRule],
        exceptions: [String] = [],
        supportDomains: [String: [String]] = BrowserDecisionCore.defaultSupportDomains
    ) {
        self.policyVersion = policyVersion
        self.mode = mode
        self.siteRules = siteRules
        self.exceptions = exceptions
        self.supportDomains = supportDomains
    }
}

public struct BrowserSiteRule: Codable, Equatable {
    public var url: String
    public var title: String?

    public init(url: String, title: String? = nil) {
        self.url = url
        self.title = title
    }
}

public struct BrowserDecisionRequest: Codable, Equatable {
    public var url: String
    public var topLevelUrl: String?
    public var browser: String?
    public var requestType: String?

    public init(
        url: String,
        topLevelUrl: String? = nil,
        browser: String? = nil,
        requestType: String? = nil
    ) {
        self.url = url
        self.topLevelUrl = topLevelUrl
        self.browser = browser
        self.requestType = requestType
    }
}

public struct BrowserDecision: Codable, Equatable {
    public var blocked: Bool
    public var reason: String
    public var source: String
    public var matchedRule: String?
    public var policyVersion: String

    public init(
        blocked: Bool,
        reason: String,
        source: String,
        matchedRule: String? = nil,
        policyVersion: String
    ) {
        self.blocked = blocked
        self.reason = reason
        self.source = source
        self.matchedRule = matchedRule
        self.policyVersion = policyVersion
    }
}

public enum BrowserDecisionCore {
    public static let blockSpecificMode = "blockSpecific"
    public static let whiteListMode = "whiteList"

    public static let defaultSupportDomains: [String: [String]] = [
        // Keep this aligned with MacGateKeeper.isRelatedToAllowedEntry.
        "docker.com": [
            "cookielaw.org",
            "adobedtm.com",
            "googletagmanager.com",
            "gstatic.com",
            "google.com",
            "newrelic.com",
            "nr-data.net",
        ],
    ]

    public static func decide(
        request: BrowserDecisionRequest,
        policy: BrowserPolicySnapshot
    ) -> BrowserDecision {
        let fullURL = request.url
        let host = extractDomain(from: fullURL).lowercased()

        guard !host.isEmpty else {
            return BrowserDecision(
                blocked: false,
                reason: "No host",
                source: "no_host",
                policyVersion: policy.policyVersion
            )
        }

        if isExcepted(fullURL: fullURL, exceptions: policy.exceptions) {
            return BrowserDecision(
                blocked: false,
                reason: "Exception match",
                source: "exception",
                policyVersion: policy.policyVersion
            )
        }

        if policy.mode == whiteListMode {
            if let rule = matchingRule(for: host, in: policy.siteRules) {
                return BrowserDecision(
                    blocked: false,
                    reason: "In allowed list",
                    source: "site_rule",
                    matchedRule: rule.url,
                    policyVersion: policy.policyVersion
                )
            }
            if let relatedRule = relatedAllowedRule(for: host, policy: policy) {
                return BrowserDecision(
                    blocked: false,
                    reason: "Related CDN",
                    source: "related_domain",
                    matchedRule: relatedRule.url,
                    policyVersion: policy.policyVersion
                )
            }
            return BrowserDecision(
                blocked: true,
                reason: "Block everything mode",
                source: "whitelist_default",
                policyVersion: policy.policyVersion
            )
        }

        guard !policy.siteRules.isEmpty else {
            return BrowserDecision(
                blocked: false,
                reason: "No entries (pass-through)",
                source: "empty_policy",
                policyVersion: policy.policyVersion
            )
        }

        if let rule = matchingRule(for: host, in: policy.siteRules) {
            return BrowserDecision(
                blocked: true,
                reason: "In blocklist",
                source: "site_rule",
                matchedRule: rule.url,
                policyVersion: policy.policyVersion
            )
        }

        return BrowserDecision(
            blocked: false,
            reason: "Not listed",
            source: "blocklist_default",
            policyVersion: policy.policyVersion
        )
    }

    public static func extractDomain(from input: String) -> String {
        var str = input.trimmingCharacters(in: .whitespacesAndNewlines)

        if let schemeRange = str.range(of: "://") {
            str = String(str[schemeRange.upperBound...])
        }

        if let slash = str.firstIndex(of: "/") {
            str = String(str[..<slash])
        }
        if let colon = str.firstIndex(of: ":") {
            str = String(str[..<colon])
        }
        if let question = str.firstIndex(of: "?") {
            str = String(str[..<question])
        }

        if str.hasPrefix("www.") {
            str = String(str.dropFirst(4))
        }

        return str
    }

    public static func isExcepted(fullURL: String, exceptions: [String]) -> Bool {
        guard !exceptions.isEmpty else { return false }
        let normalized = normalizeURLPrefix(fullURL)
        return exceptions.contains { exception in
            normalized.hasPrefix(normalizeURLPrefix(exception))
        }
    }

    public static func matchingRule(
        for host: String,
        in rules: [BrowserSiteRule]
    ) -> BrowserSiteRule? {
        let loweredHost = host.lowercased()
        return rules.first { rule in
            let domain = extractDomain(from: rule.url).lowercased()
            return loweredHost == domain || loweredHost.hasSuffix("." + domain)
        }
    }

    public static func relatedAllowedRule(
        for host: String,
        policy: BrowserPolicySnapshot
    ) -> BrowserSiteRule? {
        let loweredHost = host.lowercased()
        return policy.siteRules.first { rule in
            let allowedDomain = canonicalAllowedDomain(from: rule.url)

            if let suffixes = policy.supportDomains[allowedDomain] {
                let suffixMatch = suffixes.contains { suffix in
                    loweredHost == suffix || loweredHost.hasSuffix("." + suffix)
                }
                if suffixMatch { return true }
            }

            guard let keyword = baseKeyword(from: allowedDomain) else {
                return false
            }
            return loweredHost.contains(keyword)
        }
    }

    private static func normalizeURLPrefix(_ input: String) -> String {
        var normalized = input.lowercased()
        if let schemeRange = normalized.range(of: "://") {
            normalized = String(normalized[schemeRange.upperBound...])
        }
        if normalized.hasPrefix("www.") {
            normalized = String(normalized.dropFirst(4))
        }
        return normalized
    }

    private static func canonicalAllowedDomain(from input: String) -> String {
        let host = extractDomain(from: input).lowercased()
        if host == "www.docker.com" || host.hasSuffix(".docker.com") {
            return "docker.com"
        }
        return host
    }

    private static func baseKeyword(from domain: String) -> String? {
        let parts = domain.lowercased().split(separator: ".")
        guard parts.count >= 2 else { return nil }
        let secondLevelDomain = String(parts[parts.count - 2])
        guard secondLevelDomain.count >= 4 else { return nil }
        return secondLevelDomain
    }
}

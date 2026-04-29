import Foundation

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

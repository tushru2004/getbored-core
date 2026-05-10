//
//  SystemAllowList.swift
//  GetBored Shared
//
//  Centralised loader and matcher for the system-allowed allow-list.
//  Both MacFilter and iOSFilterDataProvider use identical load + match logic;
//  this type eliminates the duplication.
//
//  Usage:
//    let suffixes = SystemAllowList.load(from: Bundle(for: Self.self))
//    SystemAllowList.isSystemAllowed(host, suffixes: suffixes)
//

import Foundation

/// Namespace (uninstantiable) for loading and querying the system allow-list.
public enum SystemAllowList {

    /// Bare-minimum fallback used when the bundled system-allowed.json cannot be read.
    public static let fallbackSuffixes: [String] = [
        "apple.com",
        "icloud.com",
        "cdn-apple.com",
        "entrust.net",
        "digicert.com",
    ]

    /// Load the system allow-list from the `system-allowed.json` resource embedded
    /// in `bundle`.  Pass `Bundle(for: Self.self)` from each filter extension so
    /// each extension resolves resources relative to its own bundle, not Bundle.main.
    ///
    /// On any failure (file missing, malformed JSON, unexpected shape) returns
    /// `fallbackSuffixes`.
    public static func load(from bundle: Bundle) -> [String] {
        guard let url = bundle.url(forResource: "system-allowed", withExtension: "json") else {
            return fallbackSuffixes
        }
        guard let data = try? Data(contentsOf: url) else {
            return fallbackSuffixes
        }
        guard let decoded = try? JSONDecoder().decode([String: [String: [String]]].self, from: data),
              let groups = decoded["systemAllowedSuffixes"] else {
            return fallbackSuffixes
        }
        return groups.values.flatMap { $0 }
    }

    /// Returns `true` when `host` equals or is a subdomain of any entry in `suffixes`.
    ///
    /// Leading dots are stripped and the comparison is case-insensitive, matching
    /// the behaviour previously inlined in both filter extensions.
    public static func isSystemAllowed(_ host: String, suffixes: [String]) -> Bool {
        let h = host.trimmingCharacters(in: CharacterSet(charactersIn: ".")).lowercased()
        return suffixes.contains(where: { suffix in
            h == suffix || h.hasSuffix("." + suffix)
        })
    }
}

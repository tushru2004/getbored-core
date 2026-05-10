import Foundation
import XCTest
@testable import GetBoredCore

final class ChromeExtensionNativeMessageContractTests: XCTestCase {
    func testChromeExtensionNativeMessageKeysMatchCodableFixtures() throws {
        let backgroundSource = try readRepoFile("Tools/GetBoredChromeExtension/background.js")
        let nativeHostManifest = try loadJSONObject(
            fromRepoPath: "Tools/GetBoredChromeExtension/native-host/com.getbored.chrome-native-host.json"
        )

        XCTAssertEqual(
            nativeHostManifest["name"] as? String,
            GetBoredIdentifiers.NativeMessaging.chromeHostName
        )
        XCTAssertTrue(
            backgroundSource.contains("const NATIVE_HOST = '\(GetBoredIdentifiers.NativeMessaging.chromeHostName)'"),
            "background.js should send messages to the shared Chrome native host identifier."
        )

        let requestKeys = try loadFixtureKeys("browser-filter-decision-request.v1.json")
        let requestSnippet = try substring(
            in: backgroundSource,
            from: "chrome.runtime.sendNativeMessage(",
            to: "(response) => {"
        )

        XCTAssertTrue(requestSnippet.contains("NATIVE_HOST"))
        assertObjectLiteral(in: requestSnippet, containsKey: "url", mappedTo: "details.url")
        assertObjectLiteral(in: requestSnippet, containsKey: "topLevelURL", mappedTo: "details.url")
        assertObjectLiteral(in: requestSnippet, containsKey: "tabIdentifier", mappedTo: "details.tabId")
        XCTAssertEqual(requestKeys, ["tabIdentifier", "topLevelURL", "url"])

        let responseKeys = try loadFixtureKeys("browser-filter-decision-response.v1.json")
        XCTAssertEqual(responseKeys, ["policyVersion", "reason", "shouldBlock"])
        XCTAssertTrue(
            backgroundSource.contains("typeof response.shouldBlock !== 'boolean'"),
            "background.js should validate the Codable response's shouldBlock key."
        )
        XCTAssertTrue(
            backgroundSource.contains("if (response.shouldBlock)"),
            "background.js should branch on the Codable response's shouldBlock key."
        )
        XCTAssertTrue(
            backgroundSource.contains("url: blockPageUrl(details.url, response)"),
            "background.js should pass the native-host response into the block-page response flow."
        )

        let blockPageSnippet = try substring(
            in: backgroundSource,
            from: "function blockPageUrl(originalUrl, decision) {",
            to: "function isInternalUrl(url) {"
        )
        XCTAssertTrue(
            blockPageSnippet.contains("decision.reason"),
            "The block-page response flow should consume the Codable response's reason key."
        )
        XCTAssertTrue(
            blockPageSnippet.contains("decision.policyVersion"),
            "The block-page response flow should consume the Codable response's policyVersion key."
        )
    }

    private func readRepoFile(_ relativePath: String) throws -> String {
        let fileURL = repoRoot.appendingPathComponent(relativePath)
        return try String(contentsOf: fileURL, encoding: .utf8)
    }

    private func loadJSONObject(fromRepoPath relativePath: String) throws -> [String: Any] {
        let data = try Data(contentsOf: repoRoot.appendingPathComponent(relativePath))
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    private func loadFixtureKeys(_ name: String) throws -> Set<String> {
        let fixtureURL = try XCTUnwrap(
            Bundle.module.url(forResource: name, withExtension: nil, subdirectory: "Fixtures")
        )
        let fixtureData = try Data(contentsOf: fixtureURL)
        let fixtureObject = try XCTUnwrap(JSONSerialization.jsonObject(with: fixtureData) as? [String: Any])
        return Set(fixtureObject.keys)
    }

    private func substring(in source: String, from startMarker: String, to endMarker: String) throws -> String {
        let startRange = try XCTUnwrap(source.range(of: startMarker))
        let endRange = try XCTUnwrap(source[startRange.upperBound...].range(of: endMarker))
        return String(source[startRange.lowerBound..<endRange.lowerBound])
    }

    private func assertObjectLiteral(
        in source: String,
        containsKey key: String,
        mappedTo expectedValue: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let pattern = #"\b\#(NSRegularExpression.escapedPattern(for: key))\s*:\s*\#(NSRegularExpression.escapedPattern(for: expectedValue))\b"#
        XCTAssertNotNil(
            source.range(of: pattern, options: .regularExpression),
            "Expected native-message request to map \(key) to \(expectedValue).",
            file: file,
            line: line
        )
    }

    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

import Foundation
import XCTest
@testable import GetBoredCore

final class GoldenContractFixturesTests: XCTestCase {
    func testBrowserPolicySnapshotV1FixtureMatchesCodableContract() throws {
        let fixtureData = try loadFixture("browser-policy-snapshot.v1.json")
        let decoded = try JSONDecoder().decode(BrowserPolicySnapshot.self, from: fixtureData)

        XCTAssertEqual(decoded.schemaVersion, BrowserPolicySnapshot.currentSchemaVersion)
        XCTAssertEqual(decoded.policyVersion, "fixture-v1")
        XCTAssertEqual(decoded.generatedAtUnixSeconds, 1_777_000_000)
        XCTAssertEqual(decoded.loadedFilterRules.filterMode, .whiteList)
        XCTAssertEqual(decoded.loadedFilterRules.exceptions, ["docs.python.org/3"])
        XCTAssertEqual(decoded.loadedFilterRules.allowedAppBundleIDs, ["com.apple.Terminal"])
        XCTAssertEqual(decoded.loadedFilterRules.siteRules.count, 1)

        let siteRule = try XCTUnwrap(decoded.loadedFilterRules.siteRules.first)
        XCTAssertEqual(siteRule.id, UUID(uuidString: "11111111-1111-1111-1111-111111111111"))
        XCTAssertEqual(siteRule.url, "github.com")
        XCTAssertEqual(siteRule.title, "GitHub")
        XCTAssertEqual(siteRule.timestamp, Date(timeIntervalSinceReferenceDate: 800_000_000))

        let expected = BrowserPolicySnapshot(
            policyVersion: "fixture-v1",
            generatedAtUnixSeconds: 1_777_000_000,
            loadedFilterRules: LoadedFilterRules(
                siteRules: [
                    SiteRule(
                        id: try XCTUnwrap(UUID(uuidString: "11111111-1111-1111-1111-111111111111")),
                        url: "github.com",
                        title: "GitHub",
                        timestamp: Date(timeIntervalSinceReferenceDate: 800_000_000)
                    ),
                ],
                filterMode: .whiteList,
                exceptions: ["docs.python.org/3"],
                allowedAppBundleIDs: ["com.apple.Terminal"]
            )
        )

        try assertJSONObjectsEqual(JSONEncoder().encode(expected), fixtureData)
    }

    func testBrowserFilterDecisionMessageV1FixturesMatchCodableContracts() throws {
        let requestData = try loadFixture("browser-filter-decision-request.v1.json")
        let request = try JSONDecoder().decode(BrowserFilterDecisionRequest.self, from: requestData)

        XCTAssertEqual(
            request,
            BrowserFilterDecisionRequest(
                url: "https://www.youtube.com/watch?v=abc",
                topLevelURL: "https://www.youtube.com",
                tabIdentifier: 42
            )
        )

        let responseData = try loadFixture("browser-filter-decision-response.v1.json")
        let response = try JSONDecoder().decode(BrowserFilterDecisionResponse.self, from: responseData)

        XCTAssertEqual(
            response,
            BrowserFilterDecisionResponse(
                shouldBlock: true,
                reason: "Blocked by loaded filter rules",
                policyVersion: "fixture-v1"
            )
        )

        try assertJSONObjectsEqual(JSONEncoder().encode(request), requestData)
        try assertJSONObjectsEqual(JSONEncoder().encode(response), responseData)
    }

    func testActivityLogEntryV1FixtureMatchesCodableContract() throws {
        let fixtureData = try loadFixture("activity-log-entry.v1.json")
        let entry = try JSONDecoder().decode(ActivityLogEntry.self, from: fixtureData)

        XCTAssertEqual(entry.id, UUID(uuidString: "22222222-2222-2222-2222-222222222222"))
        XCTAssertEqual(entry.displayDomain, "instagram.com")
        XCTAssertEqual(entry.domain, "instagram.com")
        XCTAssertEqual(entry.rawEndpoint, "157.240.1.35")
        XCTAssertEqual(entry.resolutionSource, "sni")
        XCTAssertTrue(entry.isResolvableHostname)
        XCTAssertTrue(entry.blocked)
        XCTAssertEqual(entry.reason, "Blocked by blocklist")
        XCTAssertEqual(entry.sourceApp, "com.apple.mobilesafari")
        XCTAssertEqual(entry.timestamp, Date(timeIntervalSinceReferenceDate: 800_000_123))

        try assertJSONObjectsEqual(JSONEncoder().encode(entry), fixtureData)
    }

    private func loadFixture(_ name: String) throws -> Data {
        let fixtureURL = Bundle.module.url(forResource: name, withExtension: nil, subdirectory: "Fixtures")
        return try Data(contentsOf: try XCTUnwrap(fixtureURL))
    }

    private func assertJSONObjectsEqual(
        _ actualData: Data,
        _ expectedData: Data,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let actual = try JSONSerialization.jsonObject(with: actualData) as? NSDictionary
        let expected = try JSONSerialization.jsonObject(with: expectedData) as? NSDictionary

        XCTAssertEqual(actual, expected, file: file, line: line)
    }
}

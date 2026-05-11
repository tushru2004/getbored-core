import Foundation
import XCTest
@testable import GetBoredCore

final class GoldenContractFixturesTests: XCTestCase {
    func testSiteRuleV1FixtureMatchesCodableContract() throws {
        let fixtureData = try loadFixture("site-rule.v1.json")
        let rule = try JSONDecoder().decode(SiteRule.self, from: fixtureData)

        XCTAssertEqual(rule.id, UUID(uuidString: "11111111-1111-1111-1111-111111111111"))
        XCTAssertEqual(rule.url, "https://www.youtube.com")
        XCTAssertEqual(rule.title, "YouTube")
        XCTAssertEqual(rule.timestamp, Date(timeIntervalSinceReferenceDate: 800_000_456))

        try assertJSONObjectsEqual(JSONEncoder().encode(rule), fixtureData)
    }

    func testFilterListV1FixtureDecodesWithDefaultsForMissingOptionalFields() throws {
        // The fixture is an iOS-shaped FilterList: no `allowedApps`, no `assignedDeviceIds`.
        // Decoding must succeed and fill both fields with their empty defaults.
        let fixtureData = try loadFixture("filter-list.v1.json")
        let list = try JSONDecoder().decode(FilterList.self, from: fixtureData)

        XCTAssertEqual(list.id, UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC"))
        XCTAssertEqual(list.name, "School Filter")
        XCTAssertEqual(list.mode, .blockSpecific)
        XCTAssertTrue(list.isActive)
        // Both optional-on-wire fields must default to empty rather than throwing.
        XCTAssertEqual(list.allowedApps, [])
        XCTAssertEqual(list.assignedDeviceIds, [])
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

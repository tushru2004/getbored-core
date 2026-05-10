import XCTest
@testable import GetBoredCore

final class DecisionCoreTests: XCTestCase {
    func testLoadedFilterRulesDefaultsToEmptyBlockSpecificPolicy() {
        let loadedFilterRules = LoadedFilterRules()

        XCTAssertTrue(loadedFilterRules.siteRules.isEmpty)
        XCTAssertEqual(loadedFilterRules.filterMode, .blockSpecific)
        XCTAssertEqual(loadedFilterRules.exceptions, [])
        XCTAssertEqual(loadedFilterRules.allowedAppBundleIDs, [])
    }

    func testHostRuleMatchingCoversSubdomainsButRejectsLookalikes() {
        XCTAssertTrue(DecisionCore.matchesHostRule("github.com", rule: "github.com"))
        XCTAssertTrue(DecisionCore.matchesHostRule("https://www.github.com/tushru2004/GetBored", rule: "github.com"))
        XCTAssertFalse(DecisionCore.matchesHostRule("github.com.evil.example", rule: "github.com"))
    }

    func testShouldBlockHonorsRulesAndExceptionsInBlockSpecificMode() {
        let loadedFilterRules = LoadedFilterRules(
            siteRules: [SiteRule(url: "youtube.com", title: "YouTube")],
            exceptions: ["youtube.com/@developer"]
        )

        XCTAssertTrue(DecisionCore.shouldBlock("https://www.youtube.com/watch?v=abc", using: loadedFilterRules))
        XCTAssertFalse(DecisionCore.shouldBlock("https://www.youtube.com/@developer/videos", using: loadedFilterRules))
        XCTAssertFalse(DecisionCore.shouldBlock("https://github.com/tushru2004/GetBored", using: loadedFilterRules))
    }

    func testShouldBlockAllowsOnlyMatchingRulesInWhiteListMode() {
        let loadedFilterRules = LoadedFilterRules(
            siteRules: [SiteRule(url: "github.com", title: "GitHub")],
            filterMode: .whiteList,
            exceptions: ["docs.python.org"]
        )

        XCTAssertFalse(DecisionCore.shouldBlock("https://www.github.com/tushru2004/GetBored", using: loadedFilterRules))
        XCTAssertFalse(DecisionCore.shouldBlock("https://docs.python.org/3/library", using: loadedFilterRules))
        XCTAssertTrue(DecisionCore.shouldBlock("https://reddit.com/r/popular", using: loadedFilterRules))
    }

    func testMatchesSiteRuleUsesLoadedSiteRules() {
        let loadedFilterRules = LoadedFilterRules(siteRules: [
            SiteRule(url: "github.com", title: "github.com"),
        ])

        XCTAssertTrue(DecisionCore.matchesSiteRule("https://www.github.com/tushru2004/GetBored", using: loadedFilterRules))
        XCTAssertFalse(DecisionCore.matchesSiteRule("https://github.com.evil.example/tushru2004/GetBored", using: loadedFilterRules))
    }

    func testMatchesExceptionNormalizesSchemeAndRejectsPrefixLookalikes() {
        let loadedFilterRules = LoadedFilterRules(exceptions: [
            "github.com/tushru2004/GetBored",
        ])

        XCTAssertTrue(DecisionCore.matchesException("https://www.github.com/tushru2004/GetBored/issues", using: loadedFilterRules))
        XCTAssertFalse(DecisionCore.matchesException("https://github.com/tushru2004/GetBoredEvil", using: loadedFilterRules))
    }

    func testMatchesAllowedAppMatchesSuffixButRejectsLookalikes() {
        let loadedFilterRules = LoadedFilterRules(allowedAppBundleIDs: ["terminal"])

        XCTAssertTrue(DecisionCore.matchesAllowedApp("com.apple.Terminal", using: loadedFilterRules))
        XCTAssertFalse(DecisionCore.matchesAllowedApp("com.apple.fake-terminal", using: loadedFilterRules))
    }

    func testBrowserDecisionUsesLoadedFilterRules() {
        let loadedFilterRules = LoadedFilterRules(
            siteRules: [SiteRule(url: "youtube.com", title: "YouTube")]
        )
        let request = BrowserFilterDecisionRequest(
            url: "https://www.youtube.com/watch?v=abc",
            topLevelURL: "https://www.youtube.com",
            tabIdentifier: 42
        )

        let response = DecisionCore.browserDecision(for: request, using: loadedFilterRules)

        XCTAssertTrue(response.shouldBlock)
        XCTAssertEqual(response.reason, "Blocked by loaded filter rules")
    }

    func testBrowserDecisionMessagesRoundTripThroughJSON() throws {
        let request = BrowserFilterDecisionRequest(
            url: "https://github.com/tushru2004/GetBored",
            topLevelURL: "https://github.com",
            tabIdentifier: 7
        )
        let response = BrowserFilterDecisionResponse(
            shouldBlock: true,
            reason: "Blocked by loaded filter rules",
            policyVersion: "rules-v1"
        )

        let encodedRequest = try JSONEncoder().encode(request)
        let decodedRequest = try JSONDecoder().decode(BrowserFilterDecisionRequest.self, from: encodedRequest)
        let encodedResponse = try JSONEncoder().encode(response)
        let decodedResponse = try JSONDecoder().decode(BrowserFilterDecisionResponse.self, from: encodedResponse)

        XCTAssertEqual(decodedRequest, request)
        XCTAssertEqual(decodedResponse, response)
    }

    func testBrowserPolicySnapshotRoundTripsThroughJSON() throws {
        let snapshot = BrowserPolicySnapshot(
            policyVersion: "abc123",
            generatedAtUnixSeconds: 1_776_000_000,
            loadedFilterRules: LoadedFilterRules(
                siteRules: [SiteRule(url: "github.com", title: "GitHub")],
                filterMode: .whiteList,
                exceptions: ["docs.python.org"],
                allowedAppBundleIDs: ["com.apple.Terminal"]
            )
        )

        let encoded = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(BrowserPolicySnapshot.self, from: encoded)

        XCTAssertEqual(decoded.schemaVersion, BrowserPolicySnapshot.currentSchemaVersion)
        XCTAssertEqual(decoded.policyVersion, "abc123")
        XCTAssertEqual(decoded.generatedAtUnixSeconds, 1_776_000_000)
        XCTAssertEqual(decoded.loadedFilterRules.filterMode, .whiteList)
        XCTAssertEqual(decoded.loadedFilterRules.siteRules.map(\.url), ["github.com"])
        XCTAssertEqual(decoded.loadedFilterRules.exceptions, ["docs.python.org"])
        XCTAssertEqual(decoded.loadedFilterRules.allowedAppBundleIDs, ["com.apple.Terminal"])
    }

    func testBrowserPolicyDecisionEngineUsesSnapshotRules() throws {
        let snapshot = BrowserPolicySnapshot(
            policyVersion: "rules-v1",
            generatedAtUnixSeconds: 1_776_000_000,
            loadedFilterRules: LoadedFilterRules(
                siteRules: [SiteRule(url: "github.com", title: "GitHub")],
                filterMode: .blockSpecific
            )
        )
        let request = BrowserFilterDecisionRequest(url: "https://www.github.com/tushru2004/GetBored")

        let response = try BrowserPolicyDecisionEngine.decide(request: request, snapshot: snapshot)

        XCTAssertTrue(response.shouldBlock)
        XCTAssertEqual(response.reason, "Blocked by loaded filter rules")
        XCTAssertEqual(response.policyVersion, "rules-v1")
    }

    func testBrowserPolicyDecisionEngineCanDecodeSnapshotData() throws {
        let snapshot = BrowserPolicySnapshot(
            policyVersion: "rules-v2",
            generatedAtUnixSeconds: 1_776_000_000,
            loadedFilterRules: LoadedFilterRules(
                siteRules: [SiteRule(url: "github.com", title: "GitHub")],
                filterMode: .whiteList
            )
        )
        let snapshotData = try JSONEncoder().encode(snapshot)
        let request = BrowserFilterDecisionRequest(url: "https://reddit.com/r/popular")

        let response = try BrowserPolicyDecisionEngine.decide(request: request, snapshotData: snapshotData)

        XCTAssertTrue(response.shouldBlock)
        XCTAssertEqual(response.policyVersion, "rules-v2")
    }

    func testBrowserPolicyDecisionEngineRejectsUnknownSchemaVersion() throws {
        let snapshot = BrowserPolicySnapshot(
            schemaVersion: BrowserPolicySnapshot.currentSchemaVersion + 1,
            policyVersion: "future-rules",
            generatedAtUnixSeconds: 1_776_000_000,
            loadedFilterRules: LoadedFilterRules()
        )
        let request = BrowserFilterDecisionRequest(url: "https://github.com")

        XCTAssertThrowsError(try BrowserPolicyDecisionEngine.decide(request: request, snapshot: snapshot)) { error in
            XCTAssertEqual(
                error as? BrowserPolicyDecisionEngine.DecisionError,
                .unsupportedSchemaVersion(BrowserPolicySnapshot.currentSchemaVersion + 1)
            )
        }
    }

    func testBrowserNativeHostRunnerReadsSnapshotAndReturnsDecisionJSON() throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let snapshotURL = tempDirectory.appendingPathComponent(GetBoredIdentifiers.BrowserPolicySnapshot.fileName)
        let snapshot = BrowserPolicySnapshot(
            policyVersion: "rules-v3",
            generatedAtUnixSeconds: 1_776_000_000,
            loadedFilterRules: LoadedFilterRules(
                siteRules: [SiteRule(url: "github.com", title: "GitHub")],
                filterMode: .blockSpecific
            )
        )
        try JSONEncoder().encode(snapshot).write(to: snapshotURL)

        let request = BrowserFilterDecisionRequest(url: "https://github.com/tushru2004/GetBored")
        let responseData = try BrowserNativeHostRunner.handleRequest(
            requestData: JSONEncoder().encode(request),
            snapshotURL: snapshotURL
        )
        let response = try JSONDecoder().decode(BrowserFilterDecisionResponse.self, from: responseData)

        XCTAssertTrue(response.shouldBlock)
        XCTAssertEqual(response.reason, "Blocked by loaded filter rules")
        XCTAssertEqual(response.policyVersion, "rules-v3")
    }

    func testBrowserNativeMessageFrameRoundTripsJSONBody() throws {
        let messageData = Data(#"{"url":"https://github.com"}"#.utf8)

        let framedData = try BrowserNativeMessageFrame.encode(messageData)
        let decoded = try BrowserNativeMessageFrame.decode(framedData)

        XCTAssertEqual(decoded, messageData)
        XCTAssertEqual(Array(framedData.prefix(4)), [28, 0, 0, 0])
    }

    func testBrowserNativeMessageFrameRejectsTruncatedBody() throws {
        let framedData = Data([5, 0, 0, 0]) + Data("abc".utf8)

        XCTAssertThrowsError(try BrowserNativeMessageFrame.decode(framedData)) { error in
            XCTAssertEqual(
                error as? BrowserNativeMessageFrame.FrameError,
                .lengthMismatch(expected: 5, actual: 3)
            )
        }
    }
}

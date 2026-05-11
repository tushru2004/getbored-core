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
}

import Foundation
import XCTest
@testable import GetBoredCore

final class SharedContractsTests: XCTestCase {
    func testSiteRuleCodableRoundTrip() throws {
        let original = SiteRule(
            id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            url: "https://www.example.com",
            title: "Example",
            timestamp: Date(timeIntervalSinceReferenceDate: 700_000_000)
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SiteRule.self, from: encoded)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.url, original.url)
        XCTAssertEqual(decoded.title, original.title)
        XCTAssertEqual(decoded.timestamp, original.timestamp)
    }

    func testFilterListCodableRoundTrip() throws {
        let original = FilterList(
            id: UUID(uuidString: "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD")!,
            name: "Home Rules",
            description: "Blocks social media at home",
            entries: ["twitter.com", "facebook.com"],
            exceptions: ["twitter.com/news"],
            locations: [],
            allowedApps: ["com.apple.safari"],
            isActive: true,
            createdAt: Date(timeIntervalSinceReferenceDate: 800_000_000),
            mode: .whiteList,
            assignedDeviceIds: ["device-abc", "device-xyz"]
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FilterList.self, from: encoded)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.description, original.description)
        XCTAssertEqual(decoded.entries, original.entries)
        XCTAssertEqual(decoded.exceptions, original.exceptions)
        XCTAssertEqual(decoded.allowedApps, original.allowedApps)
        XCTAssertEqual(decoded.isActive, original.isActive)
        XCTAssertEqual(decoded.createdAt, original.createdAt)
        XCTAssertEqual(decoded.mode, original.mode)
        XCTAssertEqual(decoded.assignedDeviceIds, original.assignedDeviceIds)
    }

    func testGetBoredIdentifierContractsMatchCurrentProfilesAndTargets() {
        XCTAssertEqual(GetBoredIdentifiers.AppGroup.ios, "group.com.getbored.ios")
        XCTAssertEqual(GetBoredIdentifiers.AppGroup.iosAdvanceWhitelist, "group.com.getbored.advance.whitelist")
        XCTAssertEqual(GetBoredIdentifiers.AppGroup.macOSFilter, "group.com.getbored.macos.filter")

        XCTAssertEqual(GetBoredIdentifiers.Bundle.iOSApp, "com.getbored.filter")
        XCTAssertEqual(GetBoredIdentifiers.Bundle.iOSFilterDataProvider, "com.getbored.filter.extension")
        XCTAssertEqual(GetBoredIdentifiers.Bundle.iOSFilterControlProvider, "com.getbored.filter.control")
        XCTAssertEqual(GetBoredIdentifiers.Bundle.macOSApp, "com.getbored.macos")
        XCTAssertEqual(GetBoredIdentifiers.Bundle.macOSIOSAdmin, "com.getbored.macos.iosadmin")
        XCTAssertEqual(GetBoredIdentifiers.Bundle.macFilter, "com.getbored.macos.filter")
        XCTAssertEqual(
            GetBoredIdentifiers.Bundle.iosSafariAppProxy,
            "com.getbored.filter.safari-app-proxy-provider"
        )
        XCTAssertEqual(
            GetBoredIdentifiers.Bundle.iosSafariChildRegistration,
            "com.getbored.filter.safarichildregistration"
        )

        XCTAssertEqual(GetBoredIdentifiers.Logging.macOSApp, "com.getbored.macos")
        XCTAssertEqual(GetBoredIdentifiers.Logging.macFilter, "com.getbored.macos.filter")
        XCTAssertEqual(GetBoredIdentifiers.Logging.iOS, "com.getbored.ios")
        XCTAssertEqual(GetBoredIdentifiers.Logging.iOSFilterApp, "com.getbored.filter")
        XCTAssertEqual(GetBoredIdentifiers.Logging.iosSafariAppProxy, "com.getbored.ios.safari-app-proxy")
        XCTAssertEqual(
            GetBoredIdentifiers.Logging.iosSafariChildRegistration,
            "com.getbored.ios.safari-child-registration"
        )

        XCTAssertEqual(GetBoredIdentifiers.Profile.webFilterPayload, "com.getbored.advance.webfilter")
        XCTAssertEqual(GetBoredIdentifiers.Profile.restrictionsPayload, "com.getbored.advance.restrictions")
        XCTAssertEqual(GetBoredIdentifiers.Profile.removalPasswordPayload, "com.getbored.advance.removalpassword")
        XCTAssertEqual(GetBoredIdentifiers.Profile.advancePayload, "com.getbored.advance.profile")
        XCTAssertEqual(GetBoredIdentifiers.NativeMessaging.chromeHostName, "com.getbored.chrome_native_host")
        XCTAssertEqual(GetBoredIdentifiers.BrowserPolicySnapshot.fileName, "BrowserPolicySnapshot.json")
        XCTAssertEqual(GetBoredIdentifiers.SafariParentChild.parentChildMapKey, "parent_child_map_v1")
        XCTAssertEqual(
            GetBoredIdentifiers.DarwinNotification.iOSFilterConfigChanged,
            "com.getbored.filter.configChanged"
        )
        XCTAssertEqual(
            GetBoredIdentifiers.DarwinNotification.iOSLocationEntriesChanged,
            "com.getbored.filter.locationEntriesChanged"
        )
    }

    func testCloudKitSchemaContractsMatchCurrentWireNames() {
        XCTAssertEqual(GetBoredIdentifiers.CloudKit.containerIdentifier, "iCloud.com.getbored.sync")

        XCTAssertEqual(GetBoredIdentifiers.CloudKit.RecordType.filterConfig, "FilterConfig")
        XCTAssertEqual(GetBoredIdentifiers.CloudKit.RecordType.deviceRegistry, "DeviceRegistry")
        XCTAssertEqual(GetBoredIdentifiers.CloudKit.RecordType.whitelistConfig, "WhitelistConfig")

        XCTAssertEqual(
            GetBoredIdentifiers.CloudKit.RecordName.perDeviceFilterConfigDebug(deviceID: "device-1"),
            "FilterConfig-device-1-debug"
        )
        XCTAssertEqual(
            GetBoredIdentifiers.CloudKit.RecordName.perDeviceFilterConfigProduction(deviceID: "device-1"),
            "FilterConfig-device-1-Production"
        )
        XCTAssertEqual(GetBoredIdentifiers.CloudKit.RecordName.sharedFilterConfigDebug, "FilterConfig-debug")
        XCTAssertEqual(GetBoredIdentifiers.CloudKit.RecordName.sharedFilterConfigProduction, "FilterConfig-Production")
        XCTAssertEqual(GetBoredIdentifiers.CloudKit.RecordName.deviceRegistryDebug, "DeviceRegistry-debug")
        XCTAssertEqual(GetBoredIdentifiers.CloudKit.RecordName.deviceRegistryProduction, "DeviceRegistry-Production")

        XCTAssertEqual(GetBoredIdentifiers.CloudKit.Field.urls, "urls")
        XCTAssertEqual(GetBoredIdentifiers.CloudKit.Field.mode, "mode")
        XCTAssertEqual(GetBoredIdentifiers.CloudKit.Field.exceptions, "exceptions")
        XCTAssertEqual(GetBoredIdentifiers.CloudKit.Field.updatedAt, "updatedAt")
        XCTAssertEqual(GetBoredIdentifiers.CloudKit.Field.filterListsJSON, "filterListsJSON")
        XCTAssertEqual(GetBoredIdentifiers.CloudKit.Field.allowedApps, "allowedApps")
        XCTAssertEqual(GetBoredIdentifiers.CloudKit.Field.activityLogJSON, "activityLogJSON")
        XCTAssertEqual(GetBoredIdentifiers.CloudKit.Field.devicesJSON, "devicesJSON")
        XCTAssertEqual(GetBoredIdentifiers.CloudKit.Field.parentChildMapJSON, "parent_child_map_v1")
    }

    func testFilterModeRawValueContractMatchesPersistedWireValues() throws {
        XCTAssertEqual(FilterMode.blockSpecific.rawValue, "blockSpecific")
        XCTAssertEqual(FilterMode.whiteList.rawValue, "whiteList")
        XCTAssertEqual(FilterMode.allCases, [.blockSpecific, .whiteList])

        XCTAssertEqual(try JSONDecoder().decode(FilterMode.self, from: Data(#""blockSpecific""#.utf8)), .blockSpecific)
        XCTAssertEqual(try JSONDecoder().decode(FilterMode.self, from: Data(#""whiteList""#.utf8)), .whiteList)
        XCTAssertEqual(String(data: try JSONEncoder().encode(FilterMode.blockSpecific), encoding: .utf8), #""blockSpecific""#)
        XCTAssertEqual(String(data: try JSONEncoder().encode(FilterMode.whiteList), encoding: .utf8), #""whiteList""#)
    }

    func testCloudKitDeviceRegistryEntrySchemaRoundTripsCurrentContractShape() throws {
        let entry = CloudKitDeviceRegistryEntry(
            id: "device-1",
            deviceName: "Tushar iPhone",
            deviceModel: "iPhone",
            systemVersion: "iOS 26.4",
            appVersion: "1.2.3 (456)",
            lastSeenAt: "2026-05-10T21:00:00Z"
        )

        let jsonObject = try JSONSerialization.jsonObject(with: JSONEncoder().encode([entry])) as? [[String: Any]]
        let first = try XCTUnwrap(jsonObject?.first)

        XCTAssertEqual(first["id"] as? String, "device-1")
        XCTAssertEqual(first["deviceName"] as? String, "Tushar iPhone")
        XCTAssertEqual(first["deviceModel"] as? String, "iPhone")
        XCTAssertEqual(first["systemVersion"] as? String, "iOS 26.4")
        XCTAssertEqual(first["appVersion"] as? String, "1.2.3 (456)")
        XCTAssertEqual(first["lastSeenAt"] as? String, "2026-05-10T21:00:00Z")

        let decoded = try JSONDecoder().decode([CloudKitDeviceRegistryEntry].self, from: JSONEncoder().encode([entry]))
        XCTAssertEqual(decoded, [entry])
        XCTAssertEqual(decoded.first?.lastSeenDate, ISO8601DateFormatter().date(from: "2026-05-10T21:00:00Z"))
    }

    func testCloudKitDeviceRegistryEntryUpsertReplacesExistingDevice() {
        let oldEntry = CloudKitDeviceRegistryEntry(
            id: "device-1",
            deviceName: "Old",
            deviceModel: "iPhone",
            systemVersion: "iOS 26.3",
            appVersion: "1.0.0 (1)",
            lastSeenAt: "2026-05-01T00:00:00Z"
        )
        let otherEntry = CloudKitDeviceRegistryEntry(
            id: "device-2",
            deviceName: "Other",
            deviceModel: "Mac",
            systemVersion: "macOS 26.4",
            appVersion: "1.0.0 (1)",
            lastSeenAt: "2026-05-02T00:00:00Z"
        )
        let newEntry = CloudKitDeviceRegistryEntry(
            id: "device-1",
            deviceName: "New",
            deviceModel: "iPhone",
            systemVersion: "iOS 26.4",
            appVersion: "1.0.1 (2)",
            lastSeenAt: "2026-05-10T00:00:00Z"
        )

        let updated = CloudKitDeviceRegistryEntry.upserting(newEntry, into: [oldEntry, otherEntry])

        XCTAssertEqual(updated, [newEntry, otherEntry])
    }
}

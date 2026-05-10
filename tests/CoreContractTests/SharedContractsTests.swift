import Foundation
import XCTest
@testable import GetBoredCore

final class SharedContractsTests: XCTestCase {
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

    func testSafariParentChildContextStoreAppGroupAndKeyContracts() {
        XCTAssertEqual(SafariParentChildContextStore.appGroupIdentifier, "group.com.getbored.ios")

        XCTAssertEqual(
            SafariParentChildContextStore.activeContextDataKey,
            "safari_parent_child_active_context_v1"
        )
        XCTAssertEqual(
            SafariParentChildContextStore.flowObservationDataKey,
            "safari_parent_child_flow_observation_v1"
        )
        XCTAssertEqual(
            SafariParentChildContextStore.parentChildMapKey,
            "parent_child_map_v1"
        )
    }

    func testSafariParentChildContextStoreLegacyKeyContracts() {
        XCTAssertEqual(
            SafariParentChildContextStore.legacyLastMessageKey,
            "safari_extension_spike_last_message"
        )
        XCTAssertEqual(
            SafariParentChildContextStore.legacyLastMessageDateKey,
            "safari_extension_spike_last_message_at"
        )
        XCTAssertEqual(
            SafariParentChildContextStore.legacyActiveContextKey,
            "safari_extension_spike_active_page_context"
        )
        XCTAssertEqual(
            SafariParentChildContextStore.legacyActiveContextDateKey,
            "safari_extension_spike_active_page_context_at"
        )
        XCTAssertEqual(
            SafariParentChildContextStore.legacyActiveContextClearedDateKey,
            "safari_extension_spike_active_page_context_cleared_at"
        )
        XCTAssertEqual(
            SafariParentChildContextStore.legacyParentChildRegistryKey,
            "safari_extension_spike_parent_child_registry"
        )
        XCTAssertEqual(
            SafariParentChildContextStore.legacyFlowLogKey,
            "safari_app_proxy_spike_flows"
        )
    }

    func testSafariParentChildMapSchemaDecodesCurrentContractShape() throws {
        let json = """
        {
          "schemaVersion": 1,
          "version": "fixture-v1",
          "publishedAt": "2026-05-10T00:00:00Z",
          "rules": [
            {
              "p": "www.docker.com",
              "c": ["bam.nr-data.net", "js-agent.newrelic.com"]
            }
          ],
          "wildcards": [
            {
              "p": "www.cnbc.com",
              "c": "*.cnbcfm.com"
            }
          ]
        }
        """

        let map = try JSONDecoder().decode(
            SafariParentChildContextStore.ParentChildMap.self,
            from: Data(json.utf8)
        )

        XCTAssertEqual(map.schemaVersion, 1)
        XCTAssertEqual(map.version, "fixture-v1")
        XCTAssertEqual(map.publishedAt, "2026-05-10T00:00:00Z")
        XCTAssertEqual(map.rules, [
            SafariParentChildContextStore.ParentChildMap.Rule(
                p: "www.docker.com",
                c: ["bam.nr-data.net", "js-agent.newrelic.com"]
            ),
        ])
        XCTAssertEqual(map.wildcards, [
            SafariParentChildContextStore.ParentChildMap.Wildcard(
                p: "www.cnbc.com",
                c: "*.cnbcfm.com"
            ),
        ])
    }
}

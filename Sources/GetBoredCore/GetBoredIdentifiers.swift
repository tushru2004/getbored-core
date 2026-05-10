import Foundation

/// Single source of truth for cross-process identifiers shared between the
/// macOS app, iOS app, network/Safari extensions, and the Chrome native host.
///
/// Each identifier here is part of an implicit IPC, sandbox, CloudKit, or MDM
/// contract. Renaming any of these is a breaking change and must happen here
/// and in the matching `.entitlements`, `Info.plist`, and provisioning
/// profiles in lockstep. Consumers must reference these constants instead of
/// duplicating the literal string.
enum GetBoredIdentifiers {

    /// App-group container identifiers used by `UserDefaults(suiteName:)` and
    /// `NSFileManager.containerURL(forSecurityApplicationGroupIdentifier:)`.
    enum AppGroup {
        /// Primary iOS shared container. Backs filter rules, allowlist, parent
        /// /child Safari context, and last-sync state.
        static let ios = "group.com.getbored.ios"

        /// Legacy iOS container that pre-dates `ios` and still backs the
        /// in-app whitelist and location-block records. Keep referenced
        /// explicitly so it is not confused with `ios`.
        static let iosAdvanceWhitelist = "group.com.getbored.advance.whitelist"

        /// Primary macOS shared container. Backs MacFilter rule store and
        /// `BrowserPolicySnapshot.json` consumed by the Chrome native host.
        static let macOSFilter = "group.com.getbored.macos.filter"
    }

    /// Bundle identifiers for apps and Network/Safari extensions. These appear
    /// in entitlements, code-signing identities, and profile/MDM payloads.
    enum Bundle {
        /// iOS app bundle.
        static let iOSApp = "com.getbored.filter"

        /// iOS Network Extension data provider.
        static let iOSFilterDataProvider = "com.getbored.filter.extension"

        /// iOS Network Extension control provider.
        static let iOSFilterControlProvider = "com.getbored.filter.control"

        /// macOS app bundle.
        static let macOSApp = "com.getbored.macos"

        /// macOS iOS-admin companion bundle.
        static let macOSIOSAdmin = "com.getbored.macos.iosadmin"

        /// Mac system network filter extension.
        static let macFilter = "com.getbored.macos.filter"

        /// iOS Safari App Proxy extension.
        static let iosSafariAppProxy = "com.getbored.filter.safari-app-proxy-provider"

        /// iOS Safari child-domain registration web extension.
        static let iosSafariChildRegistration = "com.getbored.filter.safarichildregistration"
    }

    /// `os_log`/`OSLog` subsystem names. Used for `log show --predicate
    /// 'subsystem == "..."'` queries; rename here breaks log dashboards and
    /// support runbooks.
    enum Logging {
        static let macOSApp = "com.getbored.macos"
        static let macFilter = "com.getbored.macos.filter"
        static let iosSafariAppProxy = "com.getbored.ios.safari-app-proxy"
        static let iosSafariChildRegistration = "com.getbored.ios.safari-child-registration"
    }

    /// MDM / mobileconfig payload identifiers.
    enum Profile {
        static let advancePayload = "com.getbored.advance.profile"
    }

    /// Native-messaging host name used by the Chrome/Brave extension and the
    /// macOS `ChromeNativeHost` binary.
    enum NativeMessaging {
        static let chromeHostName = "com.getbored.chrome_native_host"
    }

    /// CloudKit record types and field names. The macOS app writes these and
    /// the iOS app reads them; keeping the strings in one place prevents
    /// silent field drift across devices.
    enum CloudKit {

        /// Record type names used in `CKRecord(recordType:...)`.
        enum RecordType {
            static let filterConfig = "FilterConfig"
            static let deviceRegistry = "DeviceRegistry"
            static let whitelistConfig = "WhitelistConfig"
        }

        /// Record-name templates used to construct `CKRecord.ID(recordName:)`.
        ///
        /// Both production and debug names are split here so the build-config
        /// switch lives in one place. `perDeviceFilterConfig` is the
        /// per-device record; `sharedFilterConfig` is the cross-device
        /// fallback record.
        enum RecordName {
            static func perDeviceFilterConfigDebug(deviceID: String) -> String {
                "FilterConfig-\(deviceID)-debug"
            }

            static func perDeviceFilterConfigProduction(deviceID: String) -> String {
                "FilterConfig-\(deviceID)-Production"
            }

            static let sharedFilterConfigDebug = "FilterConfig-debug"
            static let sharedFilterConfigProduction = "FilterConfig-Production"

            static let deviceRegistryDebug = "DeviceRegistry-debug"
            static let deviceRegistryProduction = "DeviceRegistry-Production"
        }

        /// Field keys used as `record["..."]` subscripts on `CKRecord`.
        ///
        /// Adding a field here is cheap; renaming one is a breaking change
        /// for any device that already wrote the old name.
        enum Field {
            static let urls = "urls"
            static let mode = "mode"
            static let exceptions = "exceptions"
            static let updatedAt = "updatedAt"
            static let filterListsJSON = "filterListsJSON"
            static let allowedApps = "allowedApps"
            static let activityLogJSON = "activityLogJSON"
            static let devicesJSON = "devicesJSON"
        }
    }
}

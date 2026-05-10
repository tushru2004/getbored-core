import Foundation

/// Single source of truth for cross-process identifiers shared between the
/// macOS app, iOS app, network/Safari extensions, and the Chrome native host.
///
/// Each identifier here is part of an implicit IPC, sandbox, CloudKit, or MDM
/// contract. Renaming any of these is a breaking change and must happen here
/// and in the matching `.entitlements`, `Info.plist`, and provisioning
/// profiles in lockstep. Consumers must reference these constants instead of
/// duplicating the literal string.
public enum GetBoredIdentifiers {

    /// App-group container identifiers used by `UserDefaults(suiteName:)` and
    /// `NSFileManager.containerURL(forSecurityApplicationGroupIdentifier:)`.
    public enum AppGroup {
        /// Primary iOS shared container. Backs filter rules, allowlist, parent
        /// /child Safari context, and last-sync state.
        public static let ios = "group.com.getbored.ios"

        /// Legacy iOS container that pre-dates `ios` and still backs the
        /// in-app whitelist and location-block records. Keep referenced
        /// explicitly so it is not confused with `ios`.
        public static let iosAdvanceWhitelist = "group.com.getbored.advance.whitelist"

        /// Primary macOS shared container. Backs MacFilter rule store and
        /// `BrowserPolicySnapshot.json` consumed by the Chrome native host.
        public static let macOSFilter = "group.com.getbored.macos.filter"
    }

    /// Bundle identifiers for apps and Network/Safari extensions. These appear
    /// in entitlements, code-signing identities, and profile/MDM payloads.
    public enum Bundle {
        /// iOS app bundle.
        public static let iOSApp = "com.getbored.filter"

        /// iOS Network Extension data provider.
        public static let iOSFilterDataProvider = "com.getbored.filter.extension"

        /// iOS Network Extension control provider.
        public static let iOSFilterControlProvider = "com.getbored.filter.control"

        /// macOS app bundle.
        public static let macOSApp = "com.getbored.macos"

        /// macOS iOS-admin companion bundle.
        public static let macOSIOSAdmin = "com.getbored.macos.iosadmin"

        /// Mac system network filter extension.
        public static let macFilter = "com.getbored.macos.filter"

        /// iOS Safari App Proxy extension.
        public static let iosSafariAppProxy = "com.getbored.filter.safari-app-proxy-provider"

        /// iOS Safari child-domain registration web extension.
        public static let iosSafariChildRegistration = "com.getbored.filter.safarichildregistration"
    }

    /// `os_log`/`OSLog` subsystem names. Used for `log show --predicate
    /// 'subsystem == "..."'` queries; rename here breaks log dashboards and
    /// support runbooks.
    public enum Logging {
        public static let macOSApp = "com.getbored.macos"
        public static let macFilter = "com.getbored.macos.filter"
        public static let iOS = "com.getbored.ios"
        public static let iOSFilterApp = "com.getbored.filter"
        public static let iosSafariAppProxy = "com.getbored.ios.safari-app-proxy"
        public static let iosSafariChildRegistration = "com.getbored.ios.safari-child-registration"
    }

    /// MDM / mobileconfig payload identifiers.
    public enum Profile {
        public static let webFilterPayload = "com.getbored.advance.webfilter"
        public static let restrictionsPayload = "com.getbored.advance.restrictions"
        public static let removalPasswordPayload = "com.getbored.advance.removalpassword"
        public static let advancePayload = "com.getbored.advance.profile"
    }

    /// Native-messaging host name used by the Chrome/Brave extension and the
    /// macOS `ChromeNativeHost` binary.
    public enum NativeMessaging {
        public static let chromeHostName = "com.getbored.chrome_native_host"
    }

    /// Browser policy snapshot shared between the macOS app and native host.
    public enum BrowserPolicySnapshot {
        public static let fileName = "BrowserPolicySnapshot.json"
    }

    /// Shared keys for Safari parent-child context and map exchange.
    public enum SafariParentChild {
        public static let parentChildMapKey = "parent_child_map_v1"
    }

    /// Reverse-DNS prefix shared by all GetBored bundle identifiers.
    /// Use this for runtime `contains`/`hasPrefix` checks instead of
    /// duplicating the literal string.
    public static let bundlePrefix = "com.getbored."

    /// `DispatchQueue` labels. Centralised here so the lint test can
    /// enforce that no call site uses a raw `"com.getbored.*"` label.
    public enum Queue {
        /// Serialises `MacRuleStore._rulesDict` mutations.
        public static let macRules = "com.getbored.macos.filter.rules"

        /// Serialises `MacActivityLogger` batch writes.
        public static let macActivityLogger = "com.getbored.macos.filter.activitylogger"

        /// Serialises `MacFilterDataProvider.trackedFlows` mutations.
        public static let macFlowTracking = "com.getbored.macos.filter.tracking"

        /// Serialises `SafariAppProxyProvider` relay dict + NWConnection mutations.
        public static let iosSafariConnections = "com.getbored.ios.safari-app-proxy.connections"

        /// Serialises `IOSActivityLogger` batch writes.
        public static let iosActivityLogger = "com.getbored.activitylogger"
    }

    /// Darwin notification names used for immediate cross-process cache refresh.
    public enum DarwinNotification {
        public static let iOSFilterConfigChanged = "com.getbored.filter.configChanged"
        public static let iOSLocationEntriesChanged = "com.getbored.filter.locationEntriesChanged"
    }

    /// CloudKit record types and field names. The macOS app writes these and
    /// the iOS app reads them; keeping the strings in one place prevents
    /// silent field drift across devices.
    public enum CloudKit {
        /// Private CloudKit container shared by the macOS app, iOS app, and
        /// iOS filter providers.
        public static let containerIdentifier = "iCloud.com.getbored.sync"

        /// Record type names used in `CKRecord(recordType:...)`.
        public enum RecordType {
            public static let filterConfig = "FilterConfig"
            public static let deviceRegistry = "DeviceRegistry"
            public static let whitelistConfig = "WhitelistConfig"
        }

        /// Record-name templates used to construct `CKRecord.ID(recordName:)`.
        ///
        /// Both production and debug names are split here so the build-config
        /// switch lives in one place. `perDeviceFilterConfig` is the
        /// per-device record; `sharedFilterConfig` is the cross-device
        /// fallback record.
        public enum RecordName {
            public static func perDeviceFilterConfigDebug(deviceID: String) -> String {
                "FilterConfig-\(deviceID)-debug"
            }

            public static func perDeviceFilterConfigProduction(deviceID: String) -> String {
                "FilterConfig-\(deviceID)-Production"
            }

            public static let sharedFilterConfigDebug = "FilterConfig-debug"
            public static let sharedFilterConfigProduction = "FilterConfig-Production"

            public static let deviceRegistryDebug = "DeviceRegistry-debug"
            public static let deviceRegistryProduction = "DeviceRegistry-Production"
        }

        /// Field keys used as `record["..."]` subscripts on `CKRecord`.
        ///
        /// Adding a field here is cheap; renaming one is a breaking change
        /// for any device that already wrote the old name.
        public enum Field {
            public static let urls = "urls"
            public static let mode = "mode"
            public static let exceptions = "exceptions"
            public static let updatedAt = "updatedAt"
            public static let filterListsJSON = "filterListsJSON"
            public static let allowedApps = "allowedApps"
            public static let activityLogJSON = "activityLogJSON"
            public static let devicesJSON = "devicesJSON"
            public static let parentChildMapJSON = GetBoredIdentifiers.SafariParentChild.parentChildMapKey
        }
    }
}

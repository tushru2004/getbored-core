import Foundation

/// Entry stored inside the CloudKit `DeviceRegistry.devicesJSON` array.
///
/// iOS and macOS both write this payload, and the macOS app reads it to show
/// registered devices. Keep this shape stable because older devices may keep
/// writing entries with the current keys.
public struct CloudKitDeviceRegistryEntry: Codable, Equatable, Identifiable {
    public let id: String
    public let deviceName: String
    public let deviceModel: String
    public let systemVersion: String
    public let appVersion: String
    public let lastSeenAt: String

    public init(
        id: String,
        deviceName: String,
        deviceModel: String,
        systemVersion: String,
        appVersion: String,
        lastSeenAt: String
    ) {
        self.id = id
        self.deviceName = deviceName
        self.deviceModel = deviceModel
        self.systemVersion = systemVersion
        self.appVersion = appVersion
        self.lastSeenAt = lastSeenAt
    }

    public init(
        id: String,
        deviceName: String,
        deviceModel: String,
        systemVersion: String,
        appVersion: String,
        lastSeenAt: Date
    ) {
        self.init(
            id: id,
            deviceName: deviceName,
            deviceModel: deviceModel,
            systemVersion: systemVersion,
            appVersion: appVersion,
            lastSeenAt: ISO8601DateFormatter().string(from: lastSeenAt)
        )
    }

    public var lastSeenDate: Date {
        ISO8601DateFormatter().date(from: lastSeenAt) ?? Date.distantPast
    }

    public static func upserting(
        _ entry: CloudKitDeviceRegistryEntry,
        into entries: [CloudKitDeviceRegistryEntry]
    ) -> [CloudKitDeviceRegistryEntry] {
        var updated = entries
        if let index = updated.firstIndex(where: { $0.id == entry.id }) {
            updated[index] = entry
        } else {
            updated.append(entry)
        }
        return updated
    }
}

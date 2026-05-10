//
//  FilterList.swift
//  GetBored (Shared)
//
//  Canonical definition of the filter list data model.
//  Used by both the macOS admin app and the iOS app.
//
//  Wire format compatibility:
//  - The iOS encoder never wrote `allowedApps` or `assignedDeviceIds`.
//  - The macOS encoder always writes both fields.
//  - `init(from:)` uses `decodeIfPresent` for both so that iOS-written
//    JSON (missing those keys) decodes cleanly on macOS without throwing.
//

import Foundation

// MARK: - Filter List Mode

/// How the domain entries in a FilterList are interpreted.
///   .blockSpecific → entries are blocked; everything else is allowed.
///   .whiteList     → entries are allowed; everything else is blocked.
public enum FilterListMode: String, Codable, CaseIterable {
    case blockSpecific = "blockSpecific"
    case whiteList = "whiteList"
}

// MARK: - Filter Location

/// A geofence circle that can activate a location-based FilterList.
public struct FilterLocation: Identifiable, Codable, Equatable {
    public var id: UUID
    public var name: String
    public var latitude: Double
    public var longitude: Double
    public var radiusMeters: Double

    public init(id: UUID = UUID(), name: String, latitude: Double, longitude: Double, radiusMeters: Double = 200) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.radiusMeters = radiusMeters
    }
}

// MARK: - Filter List

/// A named collection of domain rules with mode, exceptions, locations,
/// allowed apps, and device assignments. Synced via CloudKit between
/// the macOS admin app and the child's iPhone.
///
/// CloudKit / UserDefaults wire format:
///   - All field names are preserved exactly as CodingKeys.
///   - `allowedApps` and `assignedDeviceIds` are optional on the wire
///     (iOS never encoded them), so `init(from:)` defaults both to empty.
public struct FilterList: Identifiable, Codable, Equatable {
    public var id: UUID
    public var name: String
    public var description: String
    public var entries: [String]
    public var exceptions: [String]
    public var locations: [FilterLocation]
    /// Bundle IDs exempt from filtering. macOS admin writes this;
    /// iOS reads it but never writes it (hence the optional-decode path).
    public var allowedApps: [String]
    public var isActive: Bool
    public var createdAt: Date
    public var mode: FilterListMode
    /// Device IDs that should receive this list. macOS admin writes this;
    /// iOS never writes it (hence the optional-decode path).
    public var assignedDeviceIds: Set<String>

    /// UserDefaults key used for local persistence on both platforms.
    public static let storageKey = "getbored_filter_lists"

    public enum CodingKeys: String, CodingKey {
        case id, name, description, entries, exceptions, locations, allowedApps,
             isActive, createdAt, mode, assignedDeviceIds
    }

    public init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        entries: [String] = [],
        exceptions: [String] = [],
        locations: [FilterLocation] = [],
        allowedApps: [String] = [],
        isActive: Bool = false,
        createdAt: Date = Date(),
        mode: FilterListMode = .blockSpecific,
        assignedDeviceIds: Set<String> = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.entries = entries
        self.exceptions = exceptions
        self.locations = locations
        self.allowedApps = allowedApps
        self.isActive = isActive
        self.createdAt = createdAt
        self.mode = mode
        self.assignedDeviceIds = assignedDeviceIds
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        description = try c.decode(String.self, forKey: .description)
        entries = try c.decode([String].self, forKey: .entries)
        exceptions = (try? c.decode([String].self, forKey: .exceptions)) ?? []
        locations = (try? c.decode([FilterLocation].self, forKey: .locations)) ?? []
        // Optional on the wire: iOS never wrote these fields.
        allowedApps = (try? c.decodeIfPresent([String].self, forKey: .allowedApps)) ?? []
        isActive = try c.decode(Bool.self, forKey: .isActive)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        mode = (try? c.decode(FilterListMode.self, forKey: .mode)) ?? .blockSpecific
        // Optional on the wire: iOS never wrote this field.
        assignedDeviceIds = (try? c.decodeIfPresent(Set<String>.self, forKey: .assignedDeviceIds)) ?? []
    }
}

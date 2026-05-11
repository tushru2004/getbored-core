import Foundation
import XCTest

// Consumer-site CloudKit compliance (verifying iOS/macOS callers use
// GetBoredIdentifiers.CloudKit instead of raw strings) lives in each consumer
// repo. This file is intentionally empty — getbored-core only owns schema/contract tests.
final class CloudKitSchemaUsageTests: XCTestCase {}

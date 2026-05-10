//
//  SiteRule.swift
//  GetBored
//
//  Created by Tushar on 26.02.26.
//

import Foundation

public struct SiteRule: Identifiable, Codable {
    public let id: UUID
    public let url: String
    public let title: String
    public let timestamp: Date

    public init(id: UUID = UUID(), url: String, title: String, timestamp: Date = Date()) {
        self.id = id
        self.url = url
        self.title = title
        self.timestamp = timestamp
    }
}

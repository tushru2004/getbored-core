//
//  FilterMode.swift
//  GetBored
//
//  Created by Tushar on 26.02.26.
//

import Foundation

// MARK: - Filter Mode

public enum FilterMode: String, Codable, CaseIterable {
    case blockSpecific = "blockSpecific"
    case whiteList = "whiteList"
}

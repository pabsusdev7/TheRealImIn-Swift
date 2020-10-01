//
//  DistanceDataResponse.swift
//  TheRealImIn
//
//  Created by Pablo Albuja on 7/18/20.
//  Copyright © 2020 Ingenuity Applications. All rights reserved.
//

import Foundation

struct DistanceDataResponse: Codable {
    let rows: [Row]
    let status: String
}

struct Row: Codable {
    let elements: [Element]
}

struct Element: Codable {
    let distance: Metrics
    let duration: Metrics
}

struct Metrics: Codable {
    let text: String
    let value: Int
}

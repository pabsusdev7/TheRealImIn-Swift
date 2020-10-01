//
//  Location.swift
//  TheRealImIn
//
//  Created by Pablo Albuja on 4/16/19.
//  Copyright © 2019 Ingenuity Applications. All rights reserved.
//

import Foundation
import Firebase

struct Location {
    let locationID: String
    let description: String
    let geoLocation: GeoPoint
    let radius: Float
}

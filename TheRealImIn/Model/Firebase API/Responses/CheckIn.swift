//
//  CheckIn.swift
//  TheRealImIn
//
//  Created by Pablo Albuja on 12/14/19.
//  Copyright © 2019 Ingenuity Applications. All rights reserved.
//

import Foundation
import Firebase

struct CheckIn {
    let checkInId: String
    let checkInTime: Timestamp
    let checkOutTime: Timestamp?
    let event: Event
}

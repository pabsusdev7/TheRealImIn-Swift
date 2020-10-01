//
//  Event.swift
//  TheRealImIn
//
//  Created by Pablo Albuja on 4/16/19.
//  Copyright © 2019 Ingenuity Applications. All rights reserved.
//

import Foundation
import Firebase

struct Event {
    let eventId: String
    let code: String?
    let description: String?
    let startTime: Timestamp?
    let endTime: Timestamp?
    let active: Bool?
    let required: Bool?
    let location: Location?
    
    init(eventId: String, code: String? = nil, description: String? = nil, startTime: Timestamp? = nil,endTime: Timestamp? = nil, active: Bool? = false, required: Bool? = false,location: Location? = nil) {
        self.eventId = eventId
        self.code = code
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.active = active
        self.required = required
        self.location = location
    }
    
}

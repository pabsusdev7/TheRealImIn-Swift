//
//  ConfigUtils.swift
//  TheRealImIn
//
//  Created by Pablo Albuja on 9/30/20.
//  Copyright © 2020 Ingenuity Applications. All rights reserved.
//

import Foundation

class ConfigUtils {
    
    struct Configs: Codable {
        let googleAPIKey:String
    }
    
    class func getConfigs() -> Configs?{
        if  let path        = Bundle.main.path(forResource: "Config", ofType: "plist"),
            let xml         = FileManager.default.contents(atPath: path),
            let configs = try? PropertyListDecoder().decode(Configs.self, from: xml)
        {
            return configs
        }
        
        return nil
    }
}

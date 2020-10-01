//
//  MapUtils.swift
//  TheRealImIn
//
//  Created by Pablo Albuja on 7/18/20.
//  Copyright © 2020 Ingenuity Applications. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class MapUtils{
    
    
    class func openMapWithCoordinates(lat: Double, lon: Double){
        if (UIApplication.shared.canOpenURL(NSURL(string:"http://maps.apple.com")! as URL)) {
            UIApplication.shared.openURL(NSURL(string:
                "http://maps.apple.com/?ll=\(lat),\(lon)")! as URL)
        } else {
          NSLog("Can't use Apple Maps");
        }
    }
    
    class func getCurrentLocation(authorizedAlways: Bool, locationManager: CLLocationManager) -> CLLocation? {
        if authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }else{
            locationManager.requestWhenInUseAuthorization()
        }
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways) {
            let currentLoc = locationManager.location
            if(currentLoc != nil){
                print("CurrLoc Lat: \(currentLoc!.coordinate.latitude)")
                print("CurrLoc Long: \(currentLoc!.coordinate.longitude)")
            }
            return currentLoc
        }
        
        return nil
    }
    
    class func startMonitoring(center: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, notifyOnEntry: Bool, vc: UIViewController, locationManager: CLLocationManager) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            NotificationUtils.showErrorMessage(message: "Geofencing is not supported on this device!", action: "OK", vc: vc)
            return
        }
      
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            let message = """
            You checked-in but will have to manually check-out.
            ImIn does not have access to your location for automatic check-out.
            """
            NotificationUtils.showErrorMessage(message: message, action: "OK", vc: vc)
        }else{
            let fenceRegion = region(center: center, radius: radius, identifier: identifier, notifyOnEntry: notifyOnEntry)
            locationManager.startMonitoring(for: fenceRegion)
        }
      
      
    }
    
    
    class func stopMonitoring(identifier: String, locationManager: CLLocationManager) {
      for region in locationManager.monitoredRegions {
        guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == identifier else { continue }
        locationManager.stopMonitoring(for: circularRegion)
      }
    }
    
    class func region(center: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, notifyOnEntry: Bool) -> CLCircularRegion {
        let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        region.notifyOnEntry = notifyOnEntry
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
}

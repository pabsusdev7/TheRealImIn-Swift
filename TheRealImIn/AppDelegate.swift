//
//  AppDelegate.swift
//  TheRealImIn
//
//  Created by Pablo Albuja on 12/31/18.
//  Copyright © 2018 Ingenuity Applications. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var db: Firestore!
    var firebaseClient: FirebaseClient!
    let locationManager = CLLocationManager()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        // [START setup]
        let settings = FirestoreSettings()

        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        UNUserNotificationCenter.current().delegate = self
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        UNUserNotificationCenter.current()
          .requestAuthorization(options: options) { success, error in
            if let error = error {
              print("Error: \(error)")
            }
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func handleGeoFencingEvent(for region: CLRegion!) {
        
    firebaseClient = FirebaseClient()

    let currentDate = Date()
    firebaseClient.updateCheckIn(checkInId: region.identifier, checkOutTime: currentDate, completion: {result, error in
        guard error == nil else {
            NotificationUtils.showErrorMessage(message: "Firebase Network Error: Could not check out.", action: "OK", vc: (self.window?.rootViewController)!)
            print("Error: \(error!.localizedDescription)")
            return
        }
        if result {
            MapUtils.stopMonitoring(identifier: region.identifier, locationManager: self.locationManager)
            self.firebaseClient.getEventByCheckInId(checkInId: region.identifier, completion: self.handleEventResponse(event:error:))

        }else{
            NotificationUtils.showErrorMessage(message: "Error checking out. Try again later.", action: "OK", vc: (self.window?.rootViewController)!)
        }
    })
    }
    
    fileprivate func goToHomeScreen() {
        DataManager.shared.checkInVC.checkInId = nil
        DataManager.shared.checkInVC.selectedEvent = nil
        DataManager.shared.checkInVC.viewWillAppear(true)
    }
    
    func handleEventResponse(event: Event?, error: Error?){
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }
        if let event = event {
            let message = "Check out successful for \(event.description ?? event.eventId)!"
            // Show an alert if application is active
            if UIApplication.shared.applicationState == .active {
                goToHomeScreen()
                NotificationUtils.showSuccessMessage(message: message, action: "OK", vc: DataManager.shared.checkInVC)
            } else {
               // Otherwise present a local notification
               let notificationContent = UNMutableNotificationContent()
               notificationContent.body = message
               notificationContent.sound = UNNotificationSound.default
               notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
               let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
               let request = UNNotificationRequest(identifier: "location_change",
                                                   content: notificationContent,
                                                   trigger: trigger)
               UNUserNotificationCenter.current().add(request) { error in
                 if let error = error {
                   print("Error: \(error)")
                 }
               }
            }
        }
    }


}

extension AppDelegate: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    /*if region is CLCircularRegion {
      handleEvent(for: region)
    }*/
  }
  
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    if region is CLCircularRegion {
      handleGeoFencingEvent(for: region)
    }
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate{
    
  // This function will be called right after user tap on the notification
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

    // instantiate the view controller from storyboard
    if  response.notification.request.identifier == "location_change"{
        goToHomeScreen()
    }
    
    // tell the app that we have finished processing the user’s action / response
    completionHandler()
  }
}


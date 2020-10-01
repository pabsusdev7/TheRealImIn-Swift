//
//  FirebaseClient.swift
//  TheRealImIn
//
//  Created by Pablo Albuja on 7/17/20.
//  Copyright © 2020 Ingenuity Applications. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

class FirebaseClient {
    
    var db: Firestore!
    
    var appDel: AppDelegate!
    
    let source: FirestoreSource = .default
    
    init(){
        appDel = (UIApplication.shared.delegate as! AppDelegate)
        db = appDel.db
    }
    
    func getEvents(completion: @escaping ([Event], Error?) -> Void){
        
        var events = [Event]()
        db.collection("event")
            .whereField("endtime", isGreaterThan: Timestamp.init())
            .whereField("active", isEqualTo: true)
            .getDocuments(source: source){(querySnapshot,err) in
                guard err == nil else {
                    print("Error getting documents: \(err!.localizedDescription)")
                    completion([],err)
                    return
                }
                var eventCounter: Int = querySnapshot!.count
                if eventCounter > 0 {
                    for eventDoc in querySnapshot!.documents {
                        let locationReference = eventDoc.get("locationid") as! DocumentReference
                        eventCounter -= 1;
                        locationReference.getDocument{(document, err) in
                            guard err == nil else {
                                print("Error getting documents: \(err!.localizedDescription)")
                                completion([],err)
                                return
                            }
                            if let locationDoc = document, locationDoc.exists {
                                
                                let location = Location(locationID: locationDoc.documentID, description: locationDoc.get("description") as! String, geoLocation: locationDoc.get("geolocation") as! GeoPoint, radius: locationDoc.get("radius") as! Float)
                                
                                let event = Event(eventId: eventDoc.documentID, code: (eventDoc.get("code") as! String), description: (eventDoc.get("description") as! String), startTime: (eventDoc.get("starttime") as! Timestamp), endTime: (eventDoc.get("endtime") as! Timestamp), active: (eventDoc.get("active") as! Bool), required: (eventDoc.get("required") as! Bool), location: location)
                                
                                events.append(event)
                                
                                if eventCounter == 0 {
                                    completion(events, nil)
                                }
                            } else {
                                print("Location document does not exist")
                                completion([],nil)
                            }
                        }
                        
                        
                    }
                    
                }else{
                    completion([],nil)
                }
                
        }
    }
    
    func getAttendanceRecords(userId: String, completion: @escaping ([CheckIn], Error?) -> Void) {

        var checkIns = [CheckIn]()
        db.collection("checkin")
            .whereField("userId", isEqualTo: userId)
            .getDocuments(source: source){(querySnapshot,err) in
                guard err == nil else {
                    print("Error getting documents: \(err!.localizedDescription)")
                    completion([],err)
                    return
                }
                var checkInCounter: Int = querySnapshot!.count
                if checkInCounter > 0{
                    for checkinDoc in querySnapshot!.documents {
                        //print("\(document.documentID) => \(document.data())")
                        let eventIdReference = checkinDoc.get("eventid") as! DocumentReference
                        checkInCounter -= 1;
                        eventIdReference.getDocument { (document, error) in
                            guard error == nil else {
                                print("Error getting documents: \(error!.localizedDescription)")
                                completion([],error)
                                return
                            }
                        
                            if let eventDoc = document, eventDoc.exists {
                                
                                let locationReference = eventDoc.get("locationid") as! DocumentReference
                                
                                locationReference.getDocument{(document, error) in
                                    guard error == nil else {
                                        print("Error getting documents: \(error!.localizedDescription)")
                                        completion([],error)
                                        return
                                    }
                                    if let locationDoc = document, locationDoc.exists {
                                        
                                        let location = Location(locationID: locationDoc.documentID, description: locationDoc.get("description") as! String, geoLocation: locationDoc.get("geolocation") as! GeoPoint, radius: locationDoc.get("radius") as! Float)
                                        
                                        let event = Event(eventId: eventDoc.documentID, code: eventDoc.get("code") as? String, description: eventDoc.get("description") as? String, startTime: eventDoc.get("starttime") as? Timestamp, endTime: eventDoc.get("endtime") as? Timestamp, active: eventDoc.get("active") as? Bool, required: eventDoc.get("required") as? Bool, location: location)
                                        
                                        let checkin = CheckIn(checkInId: checkinDoc.documentID, checkInTime: checkinDoc.get("checkintime") as! Timestamp, checkOutTime: checkinDoc.get("checkouttime") as? Timestamp, event: event)
                                        checkIns.append(checkin)
                                        
                                        if checkInCounter == 0 {
                                            completion(checkIns, nil)
                                        }
                                    } else {
                                        print("Location document does not exist")
                                        completion([],nil)
                                    }
                                }
                            } else {
                                print("Event document does not exist")
                                completion([],nil)
                            }
                        }
                    }
                    
                }else{
                    completion([], nil)
                }
                
                
        }
    }
    
    func isUserCheckedIn(userId: String, completion: @escaping (String?, String?, Error?) -> Void){
        
        db.collection("checkin")
            .whereField("userId", isEqualTo: userId)
            .whereField("checkouttime", isEqualTo: NSNull())
            .getDocuments(source: source){(querySnapshot,err) in
                guard err == nil else {
                    print("Error getting documents: \(err!.localizedDescription)")
                    completion(nil,nil,err)
                    return
                }
                for checkinDoc in querySnapshot!.documents {
                    let eventIdReference = checkinDoc.get("eventid") as! DocumentReference
                    let checkInTime = checkinDoc.get("checkintime") as! Timestamp
                    eventIdReference.getDocument { (document, error) in
                        guard error == nil else {
                            print("Error getting documents: \(error!.localizedDescription)")
                            completion(nil,nil,error)
                            return
                        }
                        let eventEndTime = document?.get("endtime") as! Timestamp
                        if checkInTime.dateValue() < eventEndTime.dateValue() {
                            completion(checkinDoc.documentID,document?.documentID,nil)
                            return
                        }
                        
                    }
                }
                
                completion(nil,nil,nil)
         }
    }
    
    func getEventByCheckInId(checkInId: String, completion: @escaping (Event?, Error?) -> Void){
        
        db.collection("checkin").document(checkInId)
        .getDocument(source: source){(checkinDoc,err) in
               guard err == nil else {
                   print("Error getting document: \(err!.localizedDescription)")
                   completion(nil,err)
                   return
               }
               
               let eventIdReference = checkinDoc!.get("eventid") as! DocumentReference
               eventIdReference.getDocument { (eventDoc, error) in
                   guard error == nil else {
                       print("Error getting documents: \(error!.localizedDescription)")
                       completion(nil,error)
                       return
                   }
                    let event = Event(eventId: eventDoc!.documentID, code: eventDoc!.get("code") as? String, description: eventDoc!.get("description") as? String, startTime: eventDoc!.get("starttime") as? Timestamp, endTime: eventDoc!.get("endtime") as? Timestamp, active: eventDoc!.get("active") as? Bool, required: eventDoc!.get("required") as? Bool)
                    completion(event,nil)
                       
                   
               }
        }
    }
    
    func addCheckIn(userId: String, checkInTime: Date, eventId: String, completion: @escaping (String, Error?) -> Void){
        
        let eventRef = db.collection("event").document(eventId)
        var ref: DocumentReference? = nil
        ref = db.collection("checkin").addDocument(data: [
            "checkintime": checkInTime,
            "checkouttime": NSNull(),
            "userId": userId,
            "eventid": eventRef
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(String(), err)
            } else {
                print("Document added with ID: \(ref!.documentID)")
                completion(ref!.documentID, nil)
            }
        }
    }
    
    func updateCheckIn(checkInId: String, checkOutTime: Date, completion: @escaping (Bool, Error?) -> Void){
        
        db.collection("checkin").document(checkInId).updateData([
            "checkouttime": checkOutTime,
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
                completion(false, err)
            } else {
                print("Document successfully updated")
                completion(true, nil)
            }
        }
    }
    
    
    
}

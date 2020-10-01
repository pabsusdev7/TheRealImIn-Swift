//
//  CheckedInViewController.swift
//  TheRealImIn
//
//  Created by Pablo Albuja on 11/21/19.
//  Copyright © 2019 Ingenuity Applications. All rights reserved.
//

import UIKit
import CoreLocation

class CheckedInViewController: UIViewController {

    @IBOutlet weak var eventTitleNavItem: UINavigationItem!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventLocationDescLabel: UILabel!
    @IBOutlet weak var eventLocationMapButton: UIButton!
    @IBOutlet weak var eventRequiredLabel: UILabel!
    @IBOutlet weak var eventStartTimeLabel: UILabel!
    @IBOutlet weak var eventEndTimeLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var checkInStatusLabel: UILabel!
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var firebaseClient: FirebaseClient!
    var checkedInEvent : Event!
    var checkInId: String!
    var timer:Timer?
    let timerFormatter = DateComponentsFormatter()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseClient = FirebaseClient()
        
        timerFormatter.allowedUnits = [.hour, .minute, .second]
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        
        let location = checkedInEvent.location?.description ?? "Unknown"
        
        eventDescriptionLabel.text = checkedInEvent.description
        eventLocationDescLabel.text = location
        eventRequiredLabel.isHidden = !checkedInEvent.required!
        
        
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM dd, yyyy")
        
        eventDateLabel.text = dateFormatter.string(from:checkedInEvent.startTime!.dateValue())
        
        dateFormatter.setLocalizedDateFormatFromTemplate("hh:mm a")
        
        eventStartTimeLabel.text = dateFormatter.string(from:checkedInEvent.startTime!.dateValue())
        eventEndTimeLabel.text = dateFormatter.string(from:checkedInEvent.endTime!.dateValue())
        
        checkInStatusLabel.text = String.init(format: checkInStatusLabel.text!, checkedInEvent.description!, location)
        
    }
    
    @IBAction func checkOutAction(_ sender: Any) {
        setLoading(true)
        checkOutButton.isEnabled = false
        checkOut()
    }
    
    
    fileprivate func checkOut(){
        if let checkInId = checkInId {
            let currentDate = Date()
            firebaseClient.updateCheckIn(checkInId: checkInId, checkOutTime: currentDate, completion: {result, error in
                self.setLoading(false)
                self.checkOutButton.isEnabled = true
                guard error == nil else {
                    NotificationUtils.showErrorMessage(message: "Firebase Network Error: Could not check out.", action: "OK", vc: self)
                    print("Error: \(error!.localizedDescription)")
                    return
                }
                if result {
                    MapUtils.stopMonitoring(identifier: checkInId, locationManager: self.locationManager)
                    DataManager.shared.checkInVC.checkInId = nil
                    DataManager.shared.checkInVC.selectedEvent = nil
                    DataManager.shared.checkInVC.viewWillAppear(true)
                    self.dismiss(animated: true, completion: {
                        NotificationUtils.showSuccessMessage(message: "Check out successful!", action: "OK", vc: DataManager.shared.checkInVC)
                    })
                    
                }else{
                    NotificationUtils.showErrorMessage(message: "Error checking out. Try again.", action: "OK", vc: self)
                }
            })
        }
    }
    
    @IBAction func showMapAction(_ sender: Any) {
        
        if let location = checkedInEvent.location {
            MapUtils.openMapWithCoordinates(lat: location.geoLocation.latitude, lon: location.geoLocation.longitude)
        }
    }
    
    @IBAction func closeDetailAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onTimerFires()
    {
        timerLabel.text = timerFormatter.string(from: Date(), to: checkedInEvent.endTime!.dateValue())
        
        if timerLabel!.text == "00" {
            timerLabel.text = "Time's Up!"
            timer!.invalidate()
            timer = nil
            MapUtils.stopMonitoring(identifier: checkInId, locationManager: locationManager)
        }
    }
    
    func setLoading(_ loading: Bool){
        if loading{
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
        }else{
            loadingIndicator.stopAnimating()
        }
    }
}

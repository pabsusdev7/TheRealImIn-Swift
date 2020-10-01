//
//  AttendanceDetailViewController.swift
//  TheRealImIn
//
//  Created by Pablo Albuja on 12/18/19.
//  Copyright © 2019 Ingenuity Applications. All rights reserved.
//

import UIKit

class AttendanceDetailViewController: UIViewController {
    
    var selectedCheckIn : CheckIn!
    
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventLocationDescLabel: UILabel!
    @IBOutlet weak var eventLocationMapButton: UIButton!
    @IBOutlet weak var eventRequiredLabel: UILabel!
    @IBOutlet weak var eventStartTimeLabel: UILabel!
    @IBOutlet weak var eventEndTimeLabel: UILabel!
    @IBOutlet weak var checkInStatusImage: UIImageView!
    @IBOutlet weak var checkInStatusLabel: UILabel!
    @IBOutlet weak var checkInInTimeLabel: UILabel!
    @IBOutlet weak var checkInOutTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        
        eventDescriptionLabel.text = selectedCheckIn.event.description
        eventLocationDescLabel.text = selectedCheckIn.event.location?.description
        eventRequiredLabel.isHidden = !selectedCheckIn.event.required!
        
        
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM dd, yyyy")
        
        eventDateLabel.text = dateFormatter.string(from:selectedCheckIn.event.startTime!.dateValue())
        
        dateFormatter.setLocalizedDateFormatFromTemplate("hh:mm a")
        
        eventStartTimeLabel.text = dateFormatter.string(from:selectedCheckIn.event.startTime!.dateValue())
        eventEndTimeLabel.text = dateFormatter.string(from:selectedCheckIn.event.endTime!.dateValue())
        
        let missedCheckOut = selectedCheckIn.checkOutTime == nil && Date() > selectedCheckIn.event.endTime!.dateValue()
        let inSession = Date() <= selectedCheckIn.event.endTime!.dateValue()
        checkInStatusImage.image = UIImage(named: inSession ? "syncronize" : (missedCheckOut ? "error" : "checked"))
        checkInStatusLabel.text = inSession ? "In Session" : (missedCheckOut ? "Missed Check Out" : "Attended")
        
        dateFormatter.setLocalizedDateFormatFromTemplate("hh:mm:ss a")
        checkInInTimeLabel.text = dateFormatter.string(from: selectedCheckIn.checkInTime.dateValue())
        if let checkOutTime = selectedCheckIn.checkOutTime {
            checkInOutTimeLabel.text = dateFormatter.string(from: checkOutTime.dateValue())
        }else{
            checkInOutTimeLabel.text = "No data"
        }
    }
    
    
    @IBAction func showMapAction(_ sender: Any) {
        if let location = selectedCheckIn.event.location {
            MapUtils.openMapWithCoordinates(lat: location.geoLocation.latitude, lon: location.geoLocation.longitude)
        }
    }
    

}

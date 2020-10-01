//
//  ViewController.swift
//  TheRealImIn
//
//  Created by Pablo Albuja on 12/31/18.
//  Copyright © 2018 Ingenuity Applications. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseUI

class CheckInViewController: UIViewController, FUIAuthDelegate {
    
    var firebaseClient: FirebaseClient!
    var authUI: FUIAuth!
    var locationManager = CLLocationManager()
    var currentLoc: CLLocation!
    var eventList = [Event]()
    var selectedEvent: Event!
    var checkInId: String!
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var eventsPickerView: UIPickerView!
    @IBOutlet weak var orgLogoImageView: UIImageView!
    @IBOutlet weak var selectEventLabel: UILabel!
    @IBOutlet weak var emptyEventsLabel: UILabel!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var closeEventInfoButton: UIButton!
    @IBOutlet weak var eventInfoContainerView: UIView!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventLocationDescLabel: UILabel!
    @IBOutlet weak var eventRequiredLabel: UILabel!
    @IBOutlet weak var eventStartTimeLabel: UILabel!
    @IBOutlet weak var eventEndTimeLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var distanceDataLabel: UILabel!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        verifyAuthentication()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    fileprivate func verifyAuthentication() {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if auth.currentUser != nil {
                self.greetingLabel.text = String.init(format: "Hi, %@!", user?.displayName ?? "")
                self.signOutButton.isEnabled = true
                self.load()
            } else {
                self.signOutButton.isEnabled = false
                self.showLoginVC()
            }
        }
    }
    
    func load(){
        if orgLogoImageView.image == nil {
            getOrgLogo()
        }
        getEvents()
    }
    
    @IBAction func signOut(_ sender: Any) {
        try? authUI?.signOut()
    }
    
    func setUpAuth(){
        authUI = FUIAuth.defaultAuthUI()
        let providers: [FUIAuthProvider] = [
          FUIGoogleAuth()
        ]
        authUI!.providers = providers
        
        authUI!.delegate = self
        
    }
    
    func showLoginVC(){
       let authViewController = authUI!.authViewController()
       
       self.present(authViewController, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseClient = FirebaseClient()
        setUpAuth()
        eventsPickerView.delegate = self
        eventsPickerView.dataSource = self
        
        currentLoc = MapUtils.getCurrentLocation(authorizedAlways: false, locationManager: locationManager)
        
        DataManager.shared.checkInVC = self
    }
    
    fileprivate func isUserCheckedIn(){
        setLoading(true)
        firebaseClient.isUserCheckedIn(userId: (authUI?.auth?.currentUser!.uid)!, completion: handleUserCheckedInResponse(checkInId:eventId:error:))
    }
    
    func handleUserCheckedInResponse(checkInId: String?,eventId: String?, error: Error?){
        setLoading(false)
        if let error = error {
            NotificationUtils.showErrorMessage(message: "Firebase Network Error", action: "OK", vc: self)
            print("Error: \(error.localizedDescription)")
        }
        self.checkInId = checkInId
        if let selectedEvent = eventList.first(where: {$0.eventId == eventId}){
            self.selectedEvent = selectedEvent
        }
        updateUI()
        
    }
    
    fileprivate func getEvents() {
        setLoading(true)
        firebaseClient.getEvents(completion: handleEventsResponse(events:error:))
    }
    
    func handleEventsResponse(events: [Event], error: Error?){
        setLoading(false)
        if let error = error {
            NotificationUtils.showErrorMessage(message: "Firebase Network Error", action: "OK", vc: self)
            print("Error: \(error.localizedDescription)")
        }
        eventList = events
        eventsPickerView.reloadAllComponents()
        isUserCheckedIn()
        
    }
    
    private func getOrgLogo(){
        if let u = URL(string: "https://ingenuityapps.com/wp-content/uploads/imin/logos/default.png"){
            
            DistanceMatrixClient.getOrgImage(url: u, completion: { data, error in
                guard let data = data, error == nil else {
                    NotificationUtils.showErrorMessage(message: "Network Error. Please connect to Internet.", action: "OK", vc: self)
                    return
                }

                let image = UIImage(data: data)
                self.orgLogoImageView.image = image
                self.orgLogoImageView.center = self.view.center
                self.orgLogoImageView.contentMode = UIView.ContentMode.scaleAspectFit
            })
        }
    }

    @IBAction func closeEventInfoContainer(_ sender: Any) {
        
        eventInfoContainerView.isHidden = true
        checkInButton.isHidden = true
        detailsButton.isHidden = true
        selectEventLabel.text = "Which event are you planning to attend?"
        eventsPickerView.isHidden = false
        
    }
    
    @IBAction func checkInAction(_ sender: Any) {
        
        if checkInId != nil {
            performSegue(withIdentifier: "checkedInSegue", sender: nil)
        }else{
            checkIn()
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let controller = segue.destination as! CheckedInViewController
        
        if segue.identifier == "checkedInSegue" && selectedEvent != nil && checkInId != nil{
            controller.checkedInEvent = selectedEvent
            controller.checkInId = checkInId
        }
        
    }
    
    fileprivate func checkIn(){
        if let event = selectedEvent {
            let currentDate = Date()
            if event.endTime != nil, currentDate < event.endTime!.dateValue() {
                currentLoc = MapUtils.getCurrentLocation(authorizedAlways: false, locationManager: locationManager)
                let eventLocation = CLLocation.init(latitude: (event.location?.geoLocation.latitude)!, longitude: (event.location?.geoLocation.longitude)!)
                if currentLoc != nil && currentLoc.distance(from: eventLocation) <= Double(event.location!.radius) {
                    setLoading(true)
                    firebaseClient.addCheckIn(userId: (authUI?.auth?.currentUser!.uid)!,checkInTime: currentDate, eventId: event.eventId, completion: {result, error in
                        self.setLoading(false)
                        guard error == nil else {
                            NotificationUtils.showErrorMessage(message: "Firebase Network Error: Could not check in.", action: "OK", vc: self)
                            print("Error: \(error!.localizedDescription)")
                            return
                        }
                        if !result.isEmpty {
                            self.checkInId = result
                            //TODO: May need to relocate this request
                            self.currentLoc = MapUtils.getCurrentLocation(authorizedAlways: true, locationManager: self.locationManager)
                            MapUtils.startMonitoring(center: CLLocationCoordinate2D(latitude: eventLocation.coordinate.latitude, longitude: eventLocation.coordinate.longitude), radius: CLLocationDistance(event.location!.radius), identifier: self.checkInId, notifyOnEntry: false, vc: self, locationManager: self.locationManager)
                            self.updateUI()
                            NotificationUtils.showSuccessMessage(message: "Check in successful!", action: "OK", vc: self, segueToPerform: "checkedInSegue")
                        }else{
                            NotificationUtils.showErrorMessage(message: "Error checking in. Try again.", action: "OK", vc: self)
                        }
                    })
                }else{
                    NotificationUtils.showErrorMessage(message: "Not there yet! Get closer to the event's location.", action: "OK", vc: self)
                }
            }else{
                NotificationUtils.showErrorMessage(message: "Event not available for check in. Try again later.", action: "OK", vc: self)
            }
        }
    }
    
    fileprivate func updateUI(){
        
        
        updateEventInfo()
        
        if checkInId != nil {
            closeEventInfoButton.isHidden = true
            selectEventLabel.backgroundColor = UIColor(named: "checkin")
            selectEventLabel.textColor = .white
            selectEventLabel.text = "You're checked in!"
            
            checkInButton.isHidden = true
            detailsButton.isHidden = false
        } else{
            closeEventInfoButton.isHidden = false
            selectEventLabel.backgroundColor = .none
            selectEventLabel.textColor = .none
            
            eventInfoContainerView.isHidden = true
            checkInButton.isHidden = true
            detailsButton.isHidden = true
            selectEventLabel.text = "Which event are you planning to attend?"
            eventsPickerView.isHidden = false

        }
        
    }
    
    @IBAction func showMapAction(_ sender: Any) {
        if let location = selectedEvent.location {
            MapUtils.openMapWithCoordinates(lat: location.geoLocation.latitude, lon: location.geoLocation.longitude)
        }
        
    }
    
    
    func setLoading(_ loading: Bool){
        if loading{
            loadingIndicator.startAnimating()
        }else{
            loadingIndicator.stopAnimating()
        }
    }
    
}

extension CheckInViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if eventList.count > 0 {
            if eventInfoContainerView.isHidden {
                self.emptyEventsLabel.isHidden = true
                self.eventsPickerView.isHidden = false
                self.selectEventLabel.isHidden = false
            }
            return 1
        }else{
            self.eventsPickerView.isHidden = true
            self.selectEventLabel.isHidden = true
            self.emptyEventsLabel.isHidden = false
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return eventList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(300), height: CGFloat(37)))
        label.textAlignment = .center
        
        if eventList.isEmpty {
            label.text = "No Events"
            
        } else {
            
            switch row{
            case 0...eventList.count - 1:
                let event = self.eventList[row]
                label.text = event.description
            default:
                label.text = "Select One"
            }
        }
        return label
    }
    
    fileprivate func updateEventInfo() {
        if selectedEvent != nil {
            
            eventsPickerView.isHidden = true
            selectEventLabel.text = "Ready to check in?"
            eventInfoContainerView.isHidden = false
            checkInButton.isHidden = false
            detailsButton.isHidden = true
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            
            eventDescriptionLabel.text = selectedEvent.description
            if let location = selectedEvent.location {
                eventLocationDescLabel.text = location.description
                print("Dest Lat: \(location.geoLocation.latitude)")
                print("Dest Long: \(location.geoLocation.longitude)")
                calculateDistanceDuration(lat: location.geoLocation.latitude, lon: location.geoLocation.longitude)
            }
            
            eventRequiredLabel.isHidden = !selectedEvent.required!
            
            
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMM dd, yyyy")
            
            eventDateLabel.text = dateFormatter.string(from:selectedEvent.startTime!.dateValue())
            
            dateFormatter.setLocalizedDateFormatFromTemplate("hh:mm a")
            
            eventStartTimeLabel.text = dateFormatter.string(from:selectedEvent.startTime!.dateValue())
            eventEndTimeLabel.text = dateFormatter.string(from:selectedEvent.endTime!.dateValue())
        }
    }
    
    fileprivate func calculateDistanceDuration(lat: Double, lon: Double){
        currentLoc = MapUtils.getCurrentLocation(authorizedAlways: false, locationManager: locationManager)
        if let currentLocation = currentLoc {
            setLoading(true)
            DistanceMatrixClient.getDistanceData(latOrigin: currentLocation.coordinate.latitude, lonOrigin: currentLocation.coordinate.longitude, latDest: lat, lonDest: lon, completion: handleDistanceDurationCalulcation(element:error:))
        }
    }
    
    func handleDistanceDurationCalulcation(element: Element?, error: Error?){
        setLoading(false)
        guard error == nil else {
            NotificationUtils.showErrorMessage(message: "Network Error: Distance/Duration calculation", action: "OK", vc: self)
            return
        }
        if let element = element {
            let format = "Distance: %@\nDuration: %@"
            distanceDataLabel.text = String.init(format: format, element.distance.text, element.duration.text)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedEvent = self.eventList[row]
        
        updateEventInfo()
        
        
    }
    
}


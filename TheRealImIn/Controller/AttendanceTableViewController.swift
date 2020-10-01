//
//  AttendanceTableViewController.swift
//  TheRealImIn
//
//  Created by Pablo Albuja on 4/11/19.
//  Copyright © 2019 Ingenuity Applications. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseUI

class AttendanceTableViewController: UITableViewController, FUIAuthDelegate  {
    
    var firebaseClient: FirebaseClient!
    var attendance = [CheckIn]()
    var authUI: FUIAuth!
    var selectedCheckIn: CheckIn!
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet var attendanceTableView: UITableView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseClient = FirebaseClient()
        setUpAuth()
        
    }
    
    fileprivate func verifyAuthentication() {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if auth.currentUser != nil {
                self.refreshButton.isEnabled = true
                self.signOutButton.isEnabled = true
                self.getAttendanceRecords()
            } else {
                self.refreshButton.isEnabled = false
                self.signOutButton.isEnabled = false
                self.showLoginVC()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        verifyAuthentication()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handle!)
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
    
    private func getAttendanceRecords(){
        setLoading(true)
        
        firebaseClient.getAttendanceRecords(userId: (authUI?.auth?.currentUser!.uid)!, completion: handleAttendanceResponse(checkIns:error:))
    }
    
    func handleAttendanceResponse(checkIns: [CheckIn], error: Error?){
        setLoading(false)
        if let error = error {
            NotificationUtils.showErrorMessage(message: "Firebase Network Error", action: "OK", vc: self)
            print("Error: \(error.localizedDescription)")
        }
        attendance = checkIns
        attendanceTableView.reloadData()
     }
    
    func setLoading(_ loading: Bool){
        if loading{
            tableView.backgroundView  = loadingIndicator
            tableView.separatorStyle  = .none
            loadingIndicator.startAnimating()
        }else{
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
            loadingIndicator.stopAnimating()
        }
    }
    
    @IBAction func refreshTable(_ sender: Any) {
        getAttendanceRecords()
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! AttendanceDetailViewController
        
        if segue.identifier == "attendanceDetailSegue", let indexPath = sender as? IndexPath{
            controller.selectedCheckIn = attendance[indexPath.row]
        }
    }
    

}

extension AttendanceTableViewController {
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if attendance.count > 0 {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
            return 1
        }else{
            tableView.backgroundView  = errorLabel
            tableView.separatorStyle  = .none
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendance.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM dd, yyyy")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceTableViewCell", for: indexPath)

        let checkIn = attendance[indexPath.row]
        
        cell.textLabel?.text = checkIn.event.description
        cell.detailTextLabel?.text = "\(dateFormatter.string(from: checkIn.event.startTime!.dateValue()))"
        let missedCheckOut = checkIn.checkOutTime == nil && Date() > checkIn.event.endTime!.dateValue()
        let inSession = Date() <= checkIn.event.endTime!.dateValue()
        cell.imageView?.image = UIImage(named: inSession ? "syncronize" : (missedCheckOut ? "error" : "checked"))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "attendanceDetailSegue", sender: indexPath)
        
    }
    
}

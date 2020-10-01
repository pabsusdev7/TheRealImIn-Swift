//
//  NotificationUtils.swift
//  TheRealImIn
//
//  Created by Pablo Albuja on 7/17/20.
//  Copyright © 2020 Ingenuity Applications. All rights reserved.
//

import Foundation
import UIKit

class NotificationUtils {
    
    class func showMessage(message: String, title: String, action: String, vc: UIViewController, dismissParent: Bool, segueToPerform: String){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: action, style: .default, handler:
            !dismissParent ?
                (segueToPerform.isEmpty ? nil : {action in vc.performSegue(withIdentifier: segueToPerform, sender: nil)})
                :
                { action in vc.dismiss(animated: true, completion: nil)}
            ))
        vc.present(alertVC, animated: true, completion: nil)
    }
    
    class func showErrorMessage(message: String, action: String, vc: UIViewController, dismissParent: Bool = false, segueToPerform: String = String()){
        showMessage(message: message, title: "Error", action: action, vc: vc, dismissParent: dismissParent, segueToPerform: segueToPerform)
    }
    
    class func showSuccessMessage(message: String, action: String, vc: UIViewController, dismissParent: Bool = false, segueToPerform: String = String()){
        showMessage(message: message, title: "Success", action: action, vc: vc, dismissParent: dismissParent, segueToPerform: segueToPerform)
    }
    
    
}

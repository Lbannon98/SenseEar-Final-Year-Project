//
//  Alerts.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 16/04/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import Foundation
import UIKit

struct Alerts {
    
    /// Displays standard alert for error handling
    /// - Parameters:
    ///   - vc: View Controller for displaying alert
    ///   - title: Title mesage of the alert
    ///   - message: Message of the alert
    static func showStandardAlert(on vc: UIViewController, with title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
        
    }
    
    /// Displays alert for file that is too large
    /// - Parameter vc: View Controller for displaying alert
    static func showFileTooLargeAlert(on vc: UIViewController) {
        
        let alert = UIAlertController(title: "Select another file", message: "This file size is too large!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
        
    }
    
}

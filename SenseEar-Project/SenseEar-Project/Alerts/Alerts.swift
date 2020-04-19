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
    
    static func showStandardAlert(on vc: UIViewController, with title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
        
    }
    
}

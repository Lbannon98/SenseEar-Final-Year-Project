//
//  Keys.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 29/03/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import Foundation

/// Controls the addition of confidential keys by assigning a value to the key set in the Keys.plist
/// - Parameter keyname: Key accesses the value of the API Key
/// - Returns: Value of the API Key
func valueForAPIKey(named keyname:String) -> String {
    
    let filePath = Bundle.main.path(forResource: "Keys", ofType: "plist")
    let plist = NSDictionary(contentsOfFile:filePath!)
    let value = plist?.object(forKey: keyname) as! String
    
    return value
 
}

//
//  Keys.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 29/03/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import Foundation

func valueForAPIKey(named keyname:String) -> String {
    
    let filePath = Bundle.main.path(forResource: "Keys", ofType: "plist")
    let plist = NSDictionary(contentsOfFile:filePath!)
    let value = plist?.object(forKey: keyname) as! String
    
    return value
 
}

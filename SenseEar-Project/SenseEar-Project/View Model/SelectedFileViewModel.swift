//
//  SelectedFileViewModel.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 31/01/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import UIKit

class SelectedFileViewModel {
    
    let filename: String
    let fileTypeLogo: UIImageView
       
    init(filename: String, fileTypeLogo: UIImageView){
       self.filename = filename
       self.fileTypeLogo = fileTypeLogo
    }
    
} 

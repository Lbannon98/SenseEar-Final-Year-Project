//
//  SelectedFileViewModel.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 31/01/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import UIKit

/// View Model for selected file metadata
class SelectedFileViewModel {
    
    var filename: String
    var fileTypeLogo: UIImageView
       
    init(filename: String, fileTypeLogo: UIImageView){
       self.filename = filename
       self.fileTypeLogo = fileTypeLogo
    }
    
} 

//
//  SelectedFileView.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 29/01/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import UIKit

class SelectedFileView: UIView {

    @IBOutlet var view: UIView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        UINib(nibName: "SelectedFileView", bundle: nil).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = self.bounds
    }
    
}
 

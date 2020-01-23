//
//  CircleButton.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 17/12/2019.
//  Copyright © 2019 Lauren Bannon. All rights reserved.
//

import UIKit

@IBDesignable
class CircleButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 35.0 {
        didSet {
            setUpView()
        }
    }
    
    override func awakeFromNib() {
         setUpView()
    }
    
    func setUpView() {
        layer.cornerRadius = cornerRadius
    }
}

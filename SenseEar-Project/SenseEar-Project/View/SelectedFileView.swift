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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        UINib(nibName: "SelectedFileView", bundle: nil).instantiate(withOwner: self, options: nil)
        addSubview(view)
        view.frame = self.bounds
        
    }
    
    func setup(with viewModel: SelectedFileViewModel) {
        
        imageView.image = viewModel.fileTypeLogo.image
        label.text = viewModel.filename
        
    }
    
    func clear(with viewModel: SelectedFileViewModel) {
       
        imageView.image = nil
        label.text = ""
        
        let image = UIImage()
    
        viewModel.filename = ""
        viewModel.fileTypeLogo.image = image
        
    }

}
 

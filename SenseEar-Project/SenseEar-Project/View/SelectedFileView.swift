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
    
    let nibName = "SelectedFileView"
    
    required init(coder: NSCoder = NSCoder.empty) {
        super.init(coder: coder)!
        
        guard let views = loadViewFromNib() else { return }
        views.frame = self.bounds
        self.addSubview(views)
        view = views

    }

    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
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

extension NSCoder {
   class var empty: NSCoder {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.finishEncoding()
        return NSKeyedUnarchiver(forReadingWith: data as Data)
   }
}
 

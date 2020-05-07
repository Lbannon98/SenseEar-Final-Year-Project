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
    @IBOutlet weak var fileLogoType: UIImageView!
    @IBOutlet weak var filename: UILabel!
    
    let nibName = "SelectedFileView"
    
    required init(coder: NSCoder = NSCoder.empty) {
        super.init(coder: coder)!
        
        guard let views = loadViewFromNib() else { return }
        views.frame = self.bounds
        self.addSubview(views)
        view = views

    }
    
    /// Instaniates the view in the nib
    /// - Returns: View that will be displayed
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    /// Controls setup of view with the selected file metadata
    /// - Parameter viewModel: view model takes the parameters of the metadata
    func setup(with viewModel: SelectedFileViewModel) {
        
        fileLogoType.image = viewModel.fileTypeLogo.image
        filename.text = viewModel.filename
        
    }
    
    /// Controls the clearing of the view
    /// - Parameter viewModel: view model which takes the parameters of the metadata
    func clear(with viewModel: SelectedFileViewModel) {
       
        fileLogoType.image = nil
        filename.text = ""
        
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
 

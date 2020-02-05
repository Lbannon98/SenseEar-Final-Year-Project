//
//  ViewModelTests.swift
//  SenseEar-ProjectTests
//
//  Created by Lauren Bannon on 05/02/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import XCTest
@testable import SenseEar_Project
import Nimble

class ViewModelTests: XCTestCase {

//    let nibName = "SelectedFileView"
    
//    func testSelectedFileViewContainsAView() {
//        let bundle = Bundle(for: SelectedFileView.self)
//        guard let _ = bundle.loadNibNamed("SelectedFileView", owner: nil)?.first as? UIView else {
//          return XCTFail("CustomView nib did not contain a UIView")
//        }
//    }
    
//    func testSelectedFileViewContainsAView() {
//        let bundle = Bundle(for: type(of: self))
//        let nib = UINib(nibName: nibName, bundle: bundle)
//        nib.instantiate(withOwner: self, options: nil).first
//        
//    }
    
    func testViewModelValueAssignment() {
        
        //Given
        let image = UIImage(named: "icons8-pdf-48-2.png")
        let fileTypeLogo = UIImageView(image: image)
           
        //When
        let viewModel: SelectedFileViewModel = SelectedFileViewModel(filename: "Deadly.pdf", fileTypeLogo: fileTypeLogo)
        
        //Then
        expect(viewModel.filename).to(equal("Deadly.pdf"))
        expect(viewModel.fileTypeLogo.image).to(equal(image))
        
    }
    
    func testSelectedFileViewSetupFunctionWithViewModel() {
        
        //Given
        let image = UIImage(named: "icons8-microsoft-powerpoint-48.png")
        let fileTypeLogo = UIImageView(image: image)
           
        let selectedFileView: SelectedFileView = SelectedFileView(coder: NSCoder())!
        
        let viewModel: SelectedFileViewModel = SelectedFileViewModel(filename: "Deadly.pptx", fileTypeLogo: fileTypeLogo)
        
        //When
        selectedFileView.setup(with: viewModel)

        //Then
        expect(viewModel.fileTypeLogo.image).to(equal(selectedFileView.imageView.image))
        expect(viewModel.filename).to(equal(selectedFileView.label.text))
        
    }
    
    func testSelectedFileViewClearFunctionWithViewModel() {
        
        //Given
        let image = UIImage(named: "icons8-microsoft-word-48.png")
        let fileTypeLogo = UIImageView(image: image)
        
        let image2 = UIImage()
           
        let selectedFileView: SelectedFileView = SelectedFileView(coder: NSCoder())!
        
        let viewModel: SelectedFileViewModel = SelectedFileViewModel(filename: "Deadly.docx", fileTypeLogo: fileTypeLogo)
        
        //When
        selectedFileView.clear(with: viewModel)

        //Then
        expect(viewModel.fileTypeLogo.image).to(equal(image2))
        expect(viewModel.filename).to(equal(""))
        
        expect(selectedFileView.imageView.image).to(beNil())
        expect(selectedFileView.label.text).to(equal(""))

    }
    

}

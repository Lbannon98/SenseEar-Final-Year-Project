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
    
    var selectedFileView: SelectedFileView!

     override func setUp() {
       super.setUp()
        selectedFileView = SelectedFileView()
    }
    
    override func tearDown() {
        selectedFileView = nil
        super.tearDown()
    }
    
    func testSelectedFileViewSetupFunctionWithViewModel() {
        
        //Given
        let image = UIImage(named: "icons8-microsoft-powerpoint-48.png")
        let fileTypeLogo = UIImageView(image: image)
        
        let viewModel: SelectedFileViewModel = SelectedFileViewModel(filename: "Deadly.pptx", fileTypeLogo: fileTypeLogo)
        
        //When
        selectedFileView.setup(with: viewModel)

        //Then
        expect(viewModel.fileTypeLogo.image).to(equal(selectedFileView.fileLogoType.image))
        expect(viewModel.filename).to(equal(selectedFileView.filename.text))
        
    }
    
    func testSelectedFileViewClearFunctionWithViewModel() {

        //Given
        let image = UIImage(named: "icons8-microsoft-word-48.png")
        let fileTypeLogo = UIImageView(image: image)

        let image2 = UIImage()

        let viewModel: SelectedFileViewModel = SelectedFileViewModel(filename: "Deadly.docx", fileTypeLogo: fileTypeLogo)

        //When
        selectedFileView.clear(with: viewModel)

        //Then
        expect(viewModel.fileTypeLogo.image).to(equal(image2))
        expect(viewModel.filename).to(equal(""))

        expect(self.selectedFileView.fileLogoType.image).to(beNil())
        expect(self.selectedFileView.filename.text).to(equal(""))

    }
    
}

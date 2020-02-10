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

        let viewModel: SelectedFileViewModel = SelectedFileViewModel(filename: "Deadly.docx", fileTypeLogo: fileTypeLogo)

        //When
        selectedFileView.clear(with: viewModel)

        //Then
        expect(viewModel.fileTypeLogo.image).to(equal(image2))
        expect(viewModel.filename).to(equal(""))

        expect(self.selectedFileView.imageView.image).to(beNil())
        expect(self.selectedFileView.label.text).to(equal(""))

    }
    
}

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
    
    func testViewModelValueAssignment() {
        
        //Given
        let image = UIImage(named: "icons8-pdf-48-2.png")
        let fileTypeLogo = UIImageView(image: image)
           
        //When
        var viewModel: SelectedFileViewModel = SelectedFileViewModel(filename: "Deadly.pdf", fileTypeLogo: fileTypeLogo)
        
        //Then
        expect(viewModel.filename).to(equal("Deadly.pdf"))
        expect(viewModel.fileTypeLogo.image).to(equal(UIImage(named: "icons8-pdf-48-2.png")))
        
    }

}

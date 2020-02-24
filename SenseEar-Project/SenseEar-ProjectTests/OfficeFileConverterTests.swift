//
//  OfficeFileConverterTests.swift
//  SenseEar-ProjectTests
//
//  Created by Lauren Bannon on 24/02/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import XCTest
@testable import SenseEar_Project
import Nimble

class OfficeFileConverterTests: XCTestCase {

    func testOfficeFileConversion() {
       
        //Given
        let testBundle = Bundle(for: type(of: self))

        guard let fileURL = testBundle.url(forResource: "Intent", withExtension: "pptx")
          else { fatalError() }
        
        let inputPath = fileURL.relativePath
        let outputPath = inputPath.replacingOccurrences(of: ".\(fileURL.pathExtension)", with: ".pdf")

        //When
        OfficeFileConverter.convertOfficeDoc(with: inputPath, to: outputPath)
        
        //Then
        expect(outputPath).to(contain("Intent.pdf"))
        
    }

}

//
//  SenseEar_ProjectTests.swift
//  SenseEar-ProjectTests
//
//  Created by Lauren Bannon on 05/02/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import XCTest
@testable import SenseEar_Project
import Nimble
import FirebaseStorage

class SenseEar_ProjectTests: XCTestCase {
    
    var viewController: ViewController!
    
    override func setUp() {
      super.setUp()
        
       viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController
        
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testFirebaseStorage() {
        
        //Given
        let testBundle = Bundle(for: type(of: self))
        guard let file = testBundle.url(forResource: "TestFile", withExtension: "txt")
          else { fatalError() }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        //When
        let filename = file.lastPathComponent
        let documentRef = storageRef.child("documents/\(filename)")
        
        let uploadTask = documentRef.putFile(from: file, metadata: nil) { metadata, error in
          guard let metadata = metadata else {
            print(error!)
            return
          }
            
            //Then
            expect(metadata.name).to(equal(filename))
            expect(metadata).toNot(beNil())
        }
        
    }

    func testTextExtractionFromTextFile() {
        
        //Given
        let testBundle = Bundle(for: type(of: self))

        guard let fileURL = testBundle.url(forResource: "TestFile", withExtension: "txt")
          else { fatalError() }

        print("FILE URL: \(fileURL.description)")
        
        //When
        let textExtracted = viewController.textExtractionFromSelectedFile(url: fileURL)
        
        print("TEXT EXTRACTED: \(String(textExtracted))")
       
        //Then
        expect(textExtracted).toNot(beNil())
    }
    
    func testTextExtractionFromPDFFile() {
           
           //Given
           let testBundle = Bundle(for: type(of: self))

           guard let fileURL = testBundle.url(forResource: "Slide 3 - AI Searching Part 1", withExtension: "pdf")
             else { fatalError() }

           print("FILE URL: \(fileURL.description)")
           
           //When
           let textExtracted = viewController.textExtractionFromSelectedFile(url: fileURL)
           
           print("TEXT EXTRACTED: \(String(textExtracted))")
          
           //Then
           expect(textExtracted).toNot(beNil())
    }
    
    func testTextExtractor() {
           
           //Given
           let testBundle = Bundle(for: type(of: self))

           guard let fileURL = testBundle.url(forResource: "Slide 3 - AI Searching Part 1", withExtension: "pdf")
             else { fatalError() }

           print("FILE URL: \(fileURL.description)")
           
           //When
           let textExtracted = viewController.extractTextFromPDF(url: fileURL)
           
           print("TEXT EXTRACTED: \(String(textExtracted))")
          
           //Then
           expect(textExtracted).toNot(beNil())
    }
    
    func testtextExtractionFromSelectedFile() {
           
        //Given
        let testBundle = Bundle(for: type(of: self))

        guard let fileURL = testBundle.url(forResource: "Slide 3 - AI Searching Part 1", withExtension: "pdf")
             else { fatalError() }

        print("FILE URL: \(fileURL.description)")
           
        //When
        let textExtracted = viewController.textExtractionFromSelectedFile(url: fileURL)
           
        print("TEXT EXTRACTED: \(String(textExtracted))")
          
        //Then
        expect(textExtracted).toNot(beNil())
        
    }
    
    func testTextExtractionFromWordDoc() {
           
           //Given
           let testBundle = Bundle(for: type(of: self))

           guard let fileURL = testBundle.url(forResource: "CV - Lauren Bannon", withExtension: "docx")
             else { fatalError() }

           print("FILE URL: \(fileURL.description)")
           
           //When
           let textExtracted = viewController.textExtractionFromSelectedFile(url: fileURL)
           
           print("TEXT EXTRACTED: \(String(textExtracted))")
          
           //Then
           expect(textExtracted).toNot(beNil())
    }
    
    func testTextExtractionFromExcelDoc() {
           
           //Given
           let testBundle = Bundle(for: type(of: self))

           guard let fileURL = testBundle.url(forResource: "Module Due Dates - Semester 2", withExtension: "xlsx")
             else { fatalError() }

           print("FILE URL: \(fileURL.description)")
           
           //When
           let textExtracted = viewController.textExtractionFromSelectedFile(url: fileURL)
           
           print("TEXT EXTRACTED: \(String(textExtracted))")
          
           //Then
           expect(textExtracted).toNot(beNil())
    }
    
    func testTextExtractionFromPowerPointDoc() {
           
           //Given
           let testBundle = Bundle(for: type(of: self))

           guard let fileURL = testBundle.url(forResource: "Intent", withExtension: "pptx")
             else { fatalError() }

           print("FILE URL: \(fileURL.description)")
           
           //When
           let textExtracted = viewController.textExtractionFromSelectedFile(url: fileURL)
           
           print("TEXT EXTRACTED: \(String(textExtracted))")
          
           //Then
           expect(textExtracted).toNot(beNil())
    }

}

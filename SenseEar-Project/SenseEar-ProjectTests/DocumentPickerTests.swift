//
//  DocumentPickerTests.swift
//  SenseEar-ProjectTests
//
//  Created by Lauren Bannon on 26/04/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import XCTest
@testable import SenseEar_Project
import MobileCoreServices
import Nimble

class DocumentPickerTests: XCTestCase, UIDocumentPickerDelegate {
    
    var viewController: ViewController!
    var documentPicker: UIDocumentPickerViewController?

    override func setUp() {
      super.setUp()
        
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController
        
        documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText), String(kUTTypePlainText), String(kUTTypeContent)], in: .import)

        documentPicker!.delegate = self
        documentPicker!.allowsMultipleSelection = false
        viewController.present(documentPicker!, animated: true, completion: nil)
        
  
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testDocumentPickerSelection() {
        
       //Given
        let testBundle = Bundle(for: type(of: self))

        guard let fileURL = testBundle.url(forResource: "CV 2019", withExtension: "pdf")
           else { fatalError() }

        print("FILE URL: \(fileURL.absoluteURL)")
         
        //When
        viewController.documentPicker(documentPicker!, didPickDocumentAt: fileURL)
        let selectedFile = fileURL.absoluteURL
                 
        //Then
        expect(selectedFile).toNot(beNil())
        expect(selectedFile.absoluteURL).to(equal(fileURL.absoluteURL))
        
        
    }
    
    func testDocumentPickerWasCancelled() {
        
        //Given
        let testBundle = Bundle(for: type(of: self))

        guard let fileURL = testBundle.url(forResource: "CV 2019", withExtension: "pdf")
           else { fatalError() }

        print("FILE URL: \(fileURL.absoluteURL)")
         
        //When
        viewController.documentPickerWasCancelled(documentPicker!)
        let visible = documentPicker?.isBeingPresented
                 
        //Then
        expect(visible).to(beFalse())
        
    }

}

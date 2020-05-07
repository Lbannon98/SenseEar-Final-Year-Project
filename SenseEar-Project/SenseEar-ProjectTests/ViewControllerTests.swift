//
//  ViewControllerTests.swift
//  SenseEar-ProjectTests
//
//  Created by Lauren Bannon on 26/04/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import XCTest
@testable import SenseEar_Project
import Nimble
import FirebaseDatabase

class ViewControllerTests: XCTestCase {
    
    var viewController: ViewController!

    override func setUp() {
        super.setUp()
          
          viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController
          
    }

    override func tearDown() {
      super.tearDown()
    }
    
    func testWritingHistoryToFirebase() {
        
        //Given
        let testBundle = Bundle(for: type(of: self))
        guard let file = testBundle.url(forResource: "TestFile", withExtension: "txt")
          else { fatalError() }
        
        let firebaseDBRef = Database.database().reference()
        
        //When
        let filename = file.lastPathComponent
        
        let date = Date()
        let time = date.formatTime(format: "MM-dd-yyyy HH:mm")
        
        let historyRef = firebaseDBRef.child("history-data/\(UUID().uuidString)")
        
        historyRef.setValue([
            
            "filename" : filename,
            "time" : time
        
        ])
        
        //Then
        expect(historyRef.key).toNot(beNil())
        
    }
    
    func testTextToSpeechService() {
        
        //Given
        let testBundle = Bundle(for: type(of: self))

        guard let fileURL = testBundle.url(forResource: "TestFile", withExtension: "txt")
          else { fatalError() }
        
        let textExtracted = viewController.textExtractionFromSelectedFile(url: fileURL)
        
        let voice = VoiceTypes.ausMale
        
        //When
        TextToSpeechService.shared.makeTextToSpeechRequest(text: textExtracted, voiceType: voice) {}
        
        sleep(5)
        
        //Then
        expect(TextToSpeechService.audioData).toNot(beNil())
        
    }

}

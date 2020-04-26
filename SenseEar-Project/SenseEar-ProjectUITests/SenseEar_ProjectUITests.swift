//
//  SenseEar_ProjectUITests.swift
//  SenseEar-ProjectUITests
//
//  Created by Lauren Bannon on 26/04/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import XCTest

class SenseEar_ProjectUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
               app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testDocumentPickerOpensThenCancelIt() throws {
        
        XCUIApplication()/*@START_MENU_TOKEN@*/.staticTexts["Upload File"]/*[[".buttons[\"Upload File\"].staticTexts[\"Upload File\"]",".staticTexts[\"Upload File\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCUIApplication()/*@START_MENU_TOKEN@*/.navigationBars["FullDocumentManagerViewControllerNavigationBar"]/*[[".otherElements[\"Browse View\"].navigationBars[\"FullDocumentManagerViewControllerNavigationBar\"]",".navigationBars[\"FullDocumentManagerViewControllerNavigationBar\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["Cancel"].tap()

    }

    func testSegmentedControls() {
        
        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["Female"]/*[[".segmentedControls.buttons[\"Female\"]",".buttons[\"Female\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Male"]/*[[".segmentedControls.buttons[\"Male\"]",".buttons[\"Male\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["US"]/*[[".segmentedControls.buttons[\"US\"]",".buttons[\"US\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["AUS"]/*[[".segmentedControls.buttons[\"AUS\"]",".buttons[\"AUS\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["UK"]/*[[".segmentedControls.buttons[\"UK\"]",".buttons[\"UK\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    
    }
    
    func testAlertsShowWhenNeccessary() {
                  
        let app = XCUIApplication()
        app.buttons["play"].tap()
        
        let okButton = app.alerts["Upload File"].scrollViews.otherElements.buttons["Ok"]
        okButton.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Generate Audio"]/*[[".buttons[\"Generate Audio\"].staticTexts[\"Generate Audio\"]",".staticTexts[\"Generate Audio\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        okButton.tap()
        app.buttons["arrow.clockwise"].tap()
        okButton.tap()
        
    }
    
    
    
    
}

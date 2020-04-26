//
//  HistoryTests.swift
//  SenseEar-ProjectTests
//
//  Created by Lauren Bannon on 26/04/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import XCTest
@testable import SenseEar_Project
import Nimble

class HistoryTests: XCTestCase {

    var historyCell: HistoryCell!

    override func setUp() {
       super.setUp()
    
        historyCell = HistoryCell()
    }
    
    override func tearDown() {
        historyCell = nil
        super.tearDown()
    }
    
    func testHistoryCellDatasource() {

        //Given
        let image = UIImage(named: "icons8-pdf-48-2.png")
        let name = "Deadly.pdf"
        let date = Date()
        let time = date.formatTime(format: "MM-dd-yyyy HH:mm")

        //When
        let datasource = HistoryDataSource(image: image!, name: name, time: time)

        //Then
        expect(datasource.image).to(equal(image))
        expect(datasource.name).to(equal(name))
        expect(datasource.time).to(equal(time))

    }

}

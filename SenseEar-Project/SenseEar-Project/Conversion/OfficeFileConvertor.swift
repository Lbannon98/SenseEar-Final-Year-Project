//
//  OfficeFileConvertor.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 21/02/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import Foundation
import PDFNet

/// <#Description#>
class OfficeFileConvertor: NSObject {
    
    /// <#Description#>
    /// - Parameters:
    ///   - inputPath: <#inputPath description#>
    ///   - outputPath: <#outputPath description#>
    class func convertOfficeDoc(with inputPath: String, to outputPath: String) {
        // Start with a PDFDoc (the conversion destination)
        let pdfDoc: PTPDFDoc = PTPDFDoc()

        // perform the conversion with no optional parameters
        PTConvert.office(toPDF: pdfDoc, in_filename: inputPath, options: nil)

        pdfDoc.save(toFile: outputPath, flags: e_ptremove_unused.rawValue)

        print("Saved: \(outputPath)")
    }
}

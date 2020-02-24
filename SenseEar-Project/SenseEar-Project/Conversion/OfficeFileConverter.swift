//
//  OfficeFileConverter.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 21/02/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import Foundation
import PDFNet

/// Controls functionality behind the conversion behind Office file to pdf files
class OfficeFileConverter: NSObject {
    
    /// Fuction to convert and save the new pdf file
    /// - Parameters:
    ///   - inputPath: Input path of Office files
    ///   - outputPath: Output path of converted pdf file
    class func convertOfficeDoc(with inputPath: String, to outputPath: String) {
        // Start with a PDFDoc (the conversion destination)
        let pdfDoc: PTPDFDoc = PTPDFDoc()

        // perform the conversion with no optional parameters
        PTConvert.office(toPDF: pdfDoc, in_filename: inputPath, options: nil)

        pdfDoc.save(toFile: outputPath, flags: e_ptremove_unused.rawValue)

        print("Saved: \(outputPath)")
    }
}

//
//  TextExtractor.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 21/02/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import Foundation
import PDFKit

/// Controls the text extraction functionality for PDF Files
class TextExtractor {
    
    /// Controls text extraction from PDF files
    /// - Parameter file: takes selected file url
    func extractText(from file: URL) -> String {
        if let page = PDFDocument(url: file) {
            
            guard let extractedContent = page.string else {
                return ""
            }
            return extractedContent

        }
        return ""
    }

}

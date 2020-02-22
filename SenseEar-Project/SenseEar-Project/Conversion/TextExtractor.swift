//
//  TextExtractor.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 21/02/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import Foundation
import PDFKit

/// <#Description#>
class TextExtractor {
    
    /// <#Description#>
    /// - Parameter file: <#file description#>
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

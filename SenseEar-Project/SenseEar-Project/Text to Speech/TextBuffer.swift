//
//  TextBuffer.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 07/04/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import Foundation

/// Controls the text division of text over 5000, into separate streams
class TextBuffer {
    
    public static var firstHalfOfContents: String = ""
    public static var secondHalfOfContents: String = ""
    
    /// Controls text buffering into separat files
    /// - Parameter file: takes selected file contents
    func splitIntoSeparateBuffers(with selectedFileContents: String) -> Int {
        
        let characterCount = selectedFileContents.count
        
        if characterCount > 5000 {
            
            let contents = selectedFileContents.splitStringInHalf()
            
            TextBuffer.firstHalfOfContents = contents.firstHalf
            TextBuffer.secondHalfOfContents = contents.secondHalf
            
            let firstHalfCount = TextBuffer.firstHalfOfContents.count
            let secondHalfCount = TextBuffer.secondHalfOfContents.count
            
            print("\n")

            print("First Half:\n \(TextBuffer.firstHalfOfContents)")
            print(firstHalfCount)
            
            print("\n")
            
            print("Second Half:\n \(TextBuffer.secondHalfOfContents)")
            print(secondHalfCount)
            
        } else if characterCount > 10000 {
            
            
//            let contents = selectedFileContents.splitStringInHalf()
            
        }
        
        return characterCount
    }

}

extension String {

    func splitStringInHalf() -> (firstHalf:String, secondHalf:String) {

        let words = self.components(separatedBy: " ")
        let halfLength = words.count / 2
        let firstHalf = words[0..<halfLength].joined(separator: " ")
        let secondHalf = words[halfLength..<words.count].joined(separator: " ")

        return (firstHalf:firstHalf, secondHalf:secondHalf)

    }

}

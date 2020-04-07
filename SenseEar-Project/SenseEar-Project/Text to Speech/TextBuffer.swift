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
    
    public static var dividedContents: [String] = []
//    public static var firstHalfOfContents: String = ""
//    public static var secondHalfOfContents: String = ""
    
    /// Controls text buffering into separat files
    /// - Parameter file: takes selected file contents
    func splitIntoSeparateBuffers(with selectedFileContents: String) -> [String] {
    
        let characterCount = selectedFileContents.count
        
        if characterCount > 5000 && characterCount <= 10000 {

            let contents = selectedFileContents.splitStringBySetSize(by: characterCount / 2)
            
            TextBuffer.dividedContents.append(contents[0])
            TextBuffer.dividedContents.append(contents[1])
            
            print("\n")

            print("First Half:\n \(TextBuffer.dividedContents[0])")
            print("Character Count: \(TextBuffer.dividedContents[0].count)")
            
            print("\n")
            
            print("Second Half:\n \(TextBuffer.dividedContents[1])")
            print("Character Count: \(TextBuffer.dividedContents[1].count)")
            
        } else if characterCount > 10000 && characterCount <= 20000 {
            
            let contents = selectedFileContents.splitStringBySetSize(by: characterCount / 4)
            
            TextBuffer.dividedContents.append(contents[0])
            TextBuffer.dividedContents.append(contents[1])
            TextBuffer.dividedContents.append(contents[2])
            TextBuffer.dividedContents.append(contents[3])
            
            print("\n")

            print("First Half:\n \(TextBuffer.dividedContents[0])")
            print("Character Count: \(TextBuffer.dividedContents[0].count)")
            
            print("\n")
            
            print("Second Half:\n \(TextBuffer.dividedContents[1])")
            print("Character Count: \(TextBuffer.dividedContents[1].count)")
            
            print("\n")

            print("Third Half:\n \(TextBuffer.dividedContents[2])")
            print("Character Count: \(TextBuffer.dividedContents[2].count)")
            
            print("\n")
            
            print("Fourth Half:\n \(TextBuffer.dividedContents[3])")
            print("Character Count: \(TextBuffer.dividedContents[3].count)")
            
        } else {
            
            //TODO: Error handling - show prompt of file size being to big
            print("File size is too big!")
        }
    
        return TextBuffer.dividedContents
    
    }

}

// Mehtod to allow for Strings to be split at any length
extension String {

    func splitStringBySetSize(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()

        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }

        return results.map { String($0) }
    }
    
}

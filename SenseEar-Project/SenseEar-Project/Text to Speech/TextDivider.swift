//
//  TextBuffer.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 07/04/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import Foundation

/// Controls the division of files that contain more than 5000 charcters (Google's Text-to-Speech Limit)
class TextDivider {
    
    public static var dividedContents: [String] = []
    public static var characterCount: Int?
    
    /// Controls text buffering into separat files
    /// - Parameter file: takes selected file contents
    func splitIntoSeparateBuffers(with selectedFileContents: String) -> [String] {
    
        TextDivider.characterCount = selectedFileContents.count
        
        guard let characterCount = TextDivider.characterCount else { fatalError("Couldn't get character count") }
        
        if characterCount <= 5000 {
            
            print("This file does not need splitting")
            
        } else if characterCount > 5000 && characterCount <= 10000 {

            let contents = selectedFileContents.splitStringBySetSize(by: characterCount / 2)
            
            TextDivider.dividedContents.append(contents[0])
            TextDivider.dividedContents.append(contents[1])
            
            print("\n")

            print("First Half:\n \(TextDivider.dividedContents[0])")
            print("Character Count: \(TextDivider.dividedContents[0].count)")
            
            print("\n")
            
            print("Second Half:\n \(TextDivider.dividedContents[1])")
            print("Character Count: \(TextDivider.dividedContents[1].count)")
            
        } else if characterCount > 10000 && characterCount <= 20000 {
            
            let contents = selectedFileContents.splitStringBySetSize(by: characterCount / 4)
            
            TextDivider.dividedContents.append(contents[0])
            TextDivider.dividedContents.append(contents[1])
            TextDivider.dividedContents.append(contents[2])
            TextDivider.dividedContents.append(contents[3])
            
            print("\n")

            print("First Half:\n \(TextDivider.dividedContents[0])")
            print("Character Count: \(TextDivider.dividedContents[0].count)")
            
            print("\n")
            
            print("Second Half:\n \(TextDivider.dividedContents[1])")
            print("Character Count: \(TextDivider.dividedContents[1].count)")
            
            print("\n")

            print("Third Half:\n \(TextDivider.dividedContents[2])")
            print("Character Count: \(TextDivider.dividedContents[2].count)")
            
            print("\n")
            
            print("Fourth Half:\n \(TextDivider.dividedContents[3])")
            print("Character Count: \(TextDivider.dividedContents[3].count)")
            
        } else {
             print("Select another file, this file size is too big!")
        }
            
        return TextDivider.dividedContents
    
    }

}

extension String {

    /// Controls the splitting of strings by a given length
    /// - Parameter length: Splits the stirng by this integer
    /// - Returns: Aray fo strings which will contain the split text content
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

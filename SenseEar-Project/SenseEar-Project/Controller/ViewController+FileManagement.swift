//
//  ViewController + FileManagement.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 22/01/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import PDFKit
import PDFNet

extension ViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        selectedFile = url.absoluteURL
        filename = selectedFile?.lastPathComponent
                
        let documentRef = storageRef.child("documents/\(filename!)")
    
        let uploadTask = documentRef.putFile(from: selectedFile!, metadata: nil) { metadata, error in
          guard let metadata = metadata else {
            print(error!)
            return
          }
        }
        
        textExtractionFromSelectedFile()
    }
    
    func textExtractionFromSelectedFile() {
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let filePath = selectedFile?.relativePath
        let filePathWithoutFilename = selectedFile?.deletingLastPathComponent().relativePath
        
        do {
                    
            //Check if file exists
            if FileManager.default.fileExists(atPath: documentsDirectory.path) {
                
                if selectedFile!.pathExtension == "txt" {
                    
                    do {
                                                      
                        let data = try String(contentsOfFile: filePath!, encoding: .utf8)
                            
                        print("Text File!")
                        print("ANSWER: \(data)")
                           
                   } catch {
                       print("Text File Not Found")
                   }
                    
                } else if selectedFile!.pathExtension == "docx" {
                                        
                    do {
                            PTConvert.convertOffice(toPDF: filePath!, paperSize: .zero) { (pathToPDF) in
                            guard let pathToPDF = pathToPDF else {
                                // Failed to convert file to PDF.
                                return
                            }
                                
                                let urlToPDF = URL(fileURLWithPath: pathToPDF)
                                let destinationURL = URL(fileURLWithPath: filePathWithoutFilename!).appendingPathComponent(urlToPDF.lastPathComponent)
                                
                                self.newConvertedPdf = urlToPDF
                                    
                                do {
                                    
//                                    if let pdf = PDFDocument(url: self.newConvertedPdf!) {
//                                        let pageCount = pdf.pageCount
//                                        let documentContent = NSMutableAttributedString()
//                                        var content = String()
//
//                                        for i in 1 ..< pageCount {
//                                            guard let page = pdf.page(at: i) else { continue }
//                                            guard let pageContent = page.string else { continue }
//
//                                            content = pageContent
////                                            guard let pageContent = page.attributedString else { continue }
////                                            documentContent.append(pageContent)
////                                            content = documentContent.mutableString as String
////                                            content = pageContent.string
//                                        }
//
////                                         print("NEW PDF CONTENT: \(content)")
////
////                                        for i in 1 ..< pageCount {
////                                            guard let page = pdf.page(at: i) else { continue }
////                                            guard let pageContent = page.attributedString else { continue }
////                                            documentContent.append(pageContent)
////
////
////
////                                            print("NEW PDF CONTENT: \(documentContent)")
////                                        }
//                                    }
                                    
//                                    var pdfContents: String = ""
//
//                                    if let page = PDFDocument(url: self.newConvertedPdf!) {
//                                        pdfContents = page.string!
//
//                                        print("PDF File!")
//                                        print(pdfContents)
//
//                                    }
                                    
                                    
                                } catch {
                                    print("YOU SUCK! \(error)")
                                }
                            
                        }
                        

                    } catch {
                        print("Word Document File Not Found")
                    }
                    
                    print("Word Document!")
                    
                } else if selectedFile!.pathExtension == "pdf" {
                    
                    extractTextFromPDF()
                    
                }
                    
           } else {
               print("File does not exist!")
           }
            
        } catch CocoaError.fileReadNoSuchFile {
            
            print("CAUGHT IT!")
            
        } catch let error {
            fatalError("bad error: \(error)")
        }
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Cancelled")
    }
    
    func extractTextFromPDF() -> String {
        
        var pdfContents: String = ""
        
        if let page = PDFDocument(url: selectedFile!) {
            pdfContents = page.string!
            
            print("PDF File!")
            print(pdfContents)
                          
        }
        
        return pdfContents
    }
    
    func simpleConvert(inputPath: String, outputPath: String) {
           // Start with a PDFDoc (the conversion destination)
           let pdfDoc: PTPDFDoc = PTPDFDoc()

           // perform the conversion with no optional parameters
           PTConvert.office(toPDF: pdfDoc, in_filename: inputPath, options: nil)

           pdfDoc.save(toFile: outputPath, flags: e_ptremove_unused.rawValue)

           print("Saved: \(outputPath)")
    }

}

extension NSAttributedString {
     public func attributedStringByTrimmingCharacterSet(charSet: NSCharacterSet) -> NSAttributedString {
         let modifiedString = NSMutableAttributedString(attributedString: self)
        modifiedString.trimCharactersInSet(charSet: charSet)
         return NSAttributedString(attributedString: modifiedString)
     }
}

extension NSMutableAttributedString {
     public func trimCharactersInSet(charSet: NSCharacterSet) {
        var range = (string as NSString).rangeOfCharacter(from: charSet as CharacterSet)

         // Trim leading characters from character set.
         while range.length != 0 && range.location == 0 {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: charSet as CharacterSet)
         }

         // Trim trailing characters from character set.
        range = (string as NSString).rangeOfCharacter(from: charSet as CharacterSet, options: .backwards)
         while range.length != 0 && NSMaxRange(range) == length {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: charSet as CharacterSet, options: .backwards)
         }
     }
}

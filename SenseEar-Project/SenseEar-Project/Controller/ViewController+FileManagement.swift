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
                    
                } else if selectedFile!.pathExtension == "docx" || selectedFile!.pathExtension == "xlsx" || selectedFile!.pathExtension == "pptx" {
                                        
                    do {
                            PTConvert.convertOffice(toPDF: filePath!, paperSize: .zero) { (pathToPDF) in
                            guard let pathToPDF = pathToPDF else {
                                // Failed to convert file to PDF.
                                return
                            }
                                
                                let urlToPDF = URL(fileURLWithPath: pathToPDF)
                                let destinationURL = URL(fileURLWithPath: filePathWithoutFilename!).appendingPathComponent(urlToPDF.lastPathComponent)
                                
                                print("HERE \(filePathWithoutFilename)")
                                print(urlToPDF.lastPathComponent)
                                
                                self.newConvertedPdf = urlToPDF
                                    
                                do {
                                    
                                    var pdfContents: String = ""

                                    if let page = PDFDocument(url: self.newConvertedPdf!) {
                                        pdfContents = page.string!

                                        print("PDF File!")
                                        print(pdfContents)

                                    }
                                    
                                } catch {
                                    print("YOU SUCK! \(error)")
                                }
                            
                        }

                    } catch {
                        print("Word Document File Not Found")
                    }
                    
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
    
}

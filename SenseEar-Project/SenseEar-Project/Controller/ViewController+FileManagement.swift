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
                
                print("FILE PATH: \(filePath!)")
                
                var fileString  = String("")
                
                
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
                            
                            // Copy temporary PDF to persistent location.
//                            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, false)[0]
                            
                            let urlToPDF = URL(fileURLWithPath: pathToPDF)
                                let destinationURL = URL(fileURLWithPath: documentsDirectory.path).appendingPathComponent(urlToPDF.lastPathComponent)
                                print("DOCUMENT DIRECTORYYYYYYYY\(documentsDirectory.path)")
                            
                                
                            do {
                                
                                try FileManager.default.copyItem(at: urlToPDF, to: destinationURL)
                                print("Success!!")
                                
                            } catch {
                            
                                print("YOU SUCK! \(error)")
                                // Failed to copy item to persistent location.
                            }
                                
                                self.extractTextFromPDF()
                            // Do something with PDF output.
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

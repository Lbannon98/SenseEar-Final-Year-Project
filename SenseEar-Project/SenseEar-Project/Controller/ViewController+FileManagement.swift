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
                       print("Word Document File Not Found")
                   }
                    
                } else if selectedFile!.pathExtension == "docx" {
                    
                    do {
                        
                        let data = try NSData(contentsOfFile: selectedFile!.relativePath)
                        
//                        if let stringTry = try? NSAttributedString(data: data! as Data, documentType: .plain, encoding: .utf8) {
//                            fileString = stringTry.string
//                        } else {
//                            fileString = "Data conversion error."
//                        }
                        
                        fileString = fileString.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        print("ANSWER: \(fileString)")

                    } catch {
                        print("Word Document File Not Found")
                    }
                    
                    print("Word Document!")
                    
                } else if selectedFile!.pathExtension == "pdf" {
                    
                    if let page = PDFDocument(url: selectedFile!){
                        let pageText = page.string
                        
                        print("PDF File!")
                        print(pageText!)
                                      
                    }
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

}

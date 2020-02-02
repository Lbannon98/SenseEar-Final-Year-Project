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
        
        self.textExtractionFromSelectedFile()
        self.selectedFileInfoAttachedToView()
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
                        
                        extractedContent = try String(contentsOfFile: filePath!, encoding: .utf8)
                        print(extractedContent!)
                           
                   } catch {
                        print("No Text File Found! \(error)")
                   }
                    
                } else if selectedFile!.pathExtension == "docx" || selectedFile!.pathExtension == "xlsx" || selectedFile!.pathExtension == "pptx" {
                                        
                    do {
                            PTConvert.convertOffice(toPDF: filePath!, paperSize: .zero) { (pathToPDF) in
                            guard let pathToPDF = pathToPDF else {
                                return
                            }
                                
                                let urlToPDF = URL(fileURLWithPath: pathToPDF)
                                let destinationURL = URL(fileURLWithPath: filePathWithoutFilename!).appendingPathComponent(urlToPDF.lastPathComponent)
                                
                                self.newConvertedPdf = urlToPDF
                                    
                                do {
                                    self.extractTextFromPDF(url: self.newConvertedPdf!)
                                    
                                } catch {
                                    print("Text Extraction Failed! \(error)")
                                }
                        }

                    } catch {
                        print("Microsoft Office File Not Found!")
                    }
                    
                } else if selectedFile!.pathExtension == "pdf" {
                    
                    do {
                        
                        self.extractTextFromPDF(url: selectedFile!)
                        
                    } catch {
                        print("Text Extraction Failed! \(error)")
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
    
    func selectedFileInfoAttachedToView() {

        if selectedFile!.pathExtension == "txt" {
            
            let image = UIImage(named: "text-file-50.png")
            fileTypeLogo = UIImageView(image: image)
            
        } else if selectedFile!.pathExtension == "pdf" {
            
            let image = UIImage(named: "icons8-pdf-48-2.png")
            fileTypeLogo = UIImageView(image: image)
            
        } else if selectedFile!.pathExtension == "docx" {
            
            let image = UIImage(named: "icons8-microsoft-word-48.png")
            fileTypeLogo = UIImageView(image: image)
            
        } else if selectedFile!.pathExtension == "xlsx" {
            
            let image = UIImage(named: "icons8-microsoft-excel-48.png")
            fileTypeLogo = UIImageView(image: image)
            
        } else if selectedFile!.pathExtension == "pptx" {

            let image = UIImage(named: "icons8-microsoft-powerpoint-48.png")
            fileTypeLogo = UIImageView(image: image)
            
        }
        
        viewModel = SelectedFileViewModel(filename: filename!, fileTypeLogo: fileTypeLogo!)
        selectedFileView.setup(with: viewModel)
        
        selectedFileView.isHidden = false
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Cancelled")
    }
    
    func extractTextFromPDF(url: URL) -> String {
        
        guard let content = extractedContent else {
            return ""
        }
                
        if let page = PDFDocument(url: url) {
            extractedContent = page.string!
            
            if let content = extractedContent {
                print(content)
                return content
            }
        }
        
        return content
    }
    
}

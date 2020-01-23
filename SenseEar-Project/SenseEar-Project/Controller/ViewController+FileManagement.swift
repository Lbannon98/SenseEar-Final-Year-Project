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
        
        let filePath = documentsDirectory.appendingPathComponent(filename!)
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(atPath: documentsDirectory.path)
            
            // Print the urls of the files contained in the documents directory
            print(directoryContents)
            
            //Check if file exists
            if FileManager.default.fileExists(atPath: documentsDirectory.path) {
               do {
                let data = try String(contentsOfFile: filePath.path, encoding: .utf8)
                                      
                print(data)
                print("File does exist!")
                   
               } catch {
                    print("Error: \(error)")
                    print("Could not extract text from file!")
               }
               
           } else {
               print("File does not exist!")
           }
            
        } catch {
            print("Could not search for urls of files in documents directory: \(error)")
        }
        
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Cancelled")
    }

}

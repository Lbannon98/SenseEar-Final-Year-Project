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
    
//    private func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt urls: [URL]) {
//        /// Handle your document
//
//        guard let selectedFileURL = urls.first else {
//            return
//        }
//
//        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
//
//        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
//            print("Already Exists!")
//        } else {
//            do {
//                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
//                  print("Success!")
//            } catch {
//                print("Error: \(error)")
//            }
//        }
//    }
    
    private func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt urls: [URL]) {
        
//        guard let selectedFileURL = urls.first else {
//            return
//        }

        //Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()

        // Create a storage reference from our storage service
        let storageRef = storage.reference()

        // File located on disk
//        let localFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localFile = URL(string: "Test/TestFile.txt")!

        // Create a reference to the file you want to upload
        let documentRef = storageRef.child("doc/test.txt")
//        let documentRef = firebaseStorageReference.child("documents/test.txt")

        // Upload the file to the path "docs/rivers.pdf"
        let uploadTask = documentRef.putFile(from: localFile, metadata: nil) { metadata, error in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
//            print(error)
            return
          }

          // Metadata contains file metadata such as size, content-type.
          let size = metadata.size

           //You can also access to download URL after upload.
            storageRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
              // Uh-oh, an error occurred!
              return
            }
          }
        }
            
    }
}


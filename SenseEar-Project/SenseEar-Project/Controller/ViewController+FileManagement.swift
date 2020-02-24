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

    /// Controls the functionality behind the fille selection
    /// - Parameters:
    ///   - controller: Document Picker Controller which has been initialised in the View Controller
    ///   - url: The url of the selected file
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
        
        self.textExtractionFromSelectedFile(url: selectedFile!)
        self.selectedFileInfoAttachedToView()
    }
    
    /// Controls the functionality behind the text extraction from all file types
    /// - Parameter url: Takes the url of the selected file
    func textExtractionFromSelectedFile(url: URL) -> String {

        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return "" }

        guard let selectedFile = self.selectedFile else {
            return ""
        }
        
        let pathToFile = selectedFile.relativePath

          do {
            
              //Check if file exists
              if FileManager.default.fileExists(atPath: documentsDirectory.path) {

                      if selectedFile.pathExtension == "txt" {

                          do {

                              extractedContent = try String(contentsOfFile: pathToFile, encoding: .utf8)

                                guard let textExtracted = extractedContent else {
                                    return ""
                                }

                              print(textExtracted)

                         } catch {
                              print("No Text File Found! \(error)")
                         }

                      } else if selectedFile.pathExtension == "docx" ||
                                selectedFile.pathExtension == "xlsx" ||
                                selectedFile.pathExtension == "pptx" {

                                                        
                            // OutputPath is a relative path  built from the URL of the selectedFile
                        let outputPath = pathToFile.replacingOccurrences(of: ".\(selectedFile.pathExtension)", with: ".pdf")
                        OfficeFileConverter.convertOfficeDoc(with: pathToFile, to: outputPath)
                        
                            let pdfFileURL = URL(fileURLWithPath: outputPath)
                            self.extractedContent = self.extractTextFromPDF(url: pdfFileURL)
                            print("We might have done it!")
                        
                            print(self.extractedContent!)

                      } else if selectedFile.pathExtension == "pdf" {

                          do {

                            self.extractedContent = self.extractTextFromPDF(url: selectedFile)
                            print(self.extractedContent!)

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

        return extractedContent!

    }
    
    /// Controls the functionality behind the view being updated
    func selectedFileInfoAttachedToView() {

        guard let file = selectedFile else {
             return
        }

        if file.pathExtension == "txt" {

            let image = UIImage(named: "text-file-50.png")
            fileTypeLogo = UIImageView(image: image)

            importBtn.setTitle("Import File", for: .normal)

            selectedFileView.isHidden = false
            clearBtn.isHidden = false

        } else if file.pathExtension == "pdf" {

            let image = UIImage(named: "icons8-pdf-48-2.png")
            fileTypeLogo = UIImageView(image: image)

            importBtn.setTitle("Import File", for: .normal)

            selectedFileView.isHidden = false
            clearBtn.isHidden = false

        } else if file.pathExtension == "docx" {

            let image = UIImage(named: "icons8-microsoft-word-48.png")
            fileTypeLogo = UIImageView(image: image)

            importBtn.setTitle("Import File", for: .normal)

            selectedFileView.isHidden = false
            clearBtn.isHidden = false

        } else if file.pathExtension == "xlsx" {

            let image = UIImage(named: "icons8-microsoft-excel-48.png")
            fileTypeLogo = UIImageView(image: image)

            importBtn.setTitle("Import File", for: .normal)

            selectedFileView.isHidden = false
            clearBtn.isHidden = false

        } else if file.pathExtension == "pptx" {

            let image = UIImage(named: "icons8-microsoft-powerpoint-48.png")
            fileTypeLogo = UIImageView(image: image)

            importBtn.setTitle("Import File", for: .normal)

            selectedFileView.isHidden = false
            clearBtn.isHidden = false

        } else {

            filename = ""

            let image = UIImage()
            fileTypeLogo = UIImageView(image: image)

            selectedFileView.isHidden = true
            clearBtn.isHidden = true

            importBtn.setTitle("Not a text file! Select another file!", for: .normal)
            importBtn.isHidden = false
        }

        viewModel = SelectedFileViewModel(filename: filename!, fileTypeLogo: fileTypeLogo!)
        selectedFileView.setup(with: viewModel)

    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Cancelled")
    }

    /// Controls extraction from pdf files
    /// - Parameter url: Takes url of the pdf file
    func extractTextFromPDF(url: URL) -> String {

        let extractor = TextExtractor()
        return extractor.extractText(from: url)
        return extractedContent!
        
    }

}

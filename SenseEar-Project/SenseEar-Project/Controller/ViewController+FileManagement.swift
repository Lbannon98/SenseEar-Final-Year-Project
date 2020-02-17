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

        self.textExtractionFromSelectedFile(url: selectedFile!)
        self.selectedFileInfoAttachedToView()
    }

    func textExtractionFromSelectedFile(url: URL) -> String {

        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return "" }

        let filePath = selectedFile?.relativePath
        let filePathWithoutFilename = selectedFile?.deletingLastPathComponent().relativePath

          do {

              //Check if file exists
              if FileManager.default.fileExists(atPath: documentsDirectory.path) {

                  guard let file = selectedFile else {
                      return ""
                  }

                    guard let pathToFile = filePath else {
                        return ""
                    }

                      if file.pathExtension == "txt" {

                          do {

                              extractedContent = try String(contentsOfFile: pathToFile, encoding: .utf8)

                                guard let textExtracted = extractedContent else {
                                    return ""
                                }

                              print(textExtracted)

                         } catch {
                              print("No Text File Found! \(error)")
                         }

                      } else if file.pathExtension == "docx" || file.pathExtension == "xlsx" || file.pathExtension == "pptx" {

                          do {

                              PTConvert.convertOffice(toPDF: pathToFile, paperSize: .zero) { (pathToPDF) in
                                  guard let pathToNewPDF = pathToPDF else {
                                      return
                                  }

                                  let urlToPDF = URL(fileURLWithPath: pathToNewPDF)

                                    self.newConvertedPdf = urlToPDF

                                    guard let newPDFFile = self.newConvertedPdf else {
                                        return
                                    }

                                    print("newPDFFile: \(newPDFFile)")

                                  do {

                                    self.extractTextFromPDF(url: newPDFFile)
    //                                        self.extractedContent = self.extractTextFromMicrosoftOfficeFiles(url: urlToPDF)

                                  } catch {
                                      print("Text Extraction Failed! \(error)")
                                  }
                              }

                          } catch {
                              print("Microsoft Office File Not Found!")
                          }

                      } else if file.pathExtension == "pdf" {

                          do {

                              self.extractTextFromPDF(url: file)

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

    func extractTextFromPDF(url: URL) -> String {

        if let page = PDFDocument(url: url) {
            extractedContent = page.string!

            guard let content = extractedContent else {
                return ""
            }

            print(content)
            return content

        }

        return extractedContent!
    }

//    func extractTextFromMicrosoftOfficeFiles(url: URL) -> String {
//
//        if let page = PDFDocument(url: url) {
//            newPDFExtractedContent = page.string!
//
//            guard let content = newPDFExtractedContent else {
//                return ""
//            }
//
//            print(content)
//            return content
//
//        }
//
//        return newPDFExtractedContent!
//    }

}

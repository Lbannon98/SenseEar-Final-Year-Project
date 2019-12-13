//
//  ViewController.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 08/12/2019.
//  Copyright © 2019 Lauren Bannon. All rights reserved.
//

import UIKit
import MobileCoreServices

enum GenderSelection: Int, CaseIterable, Identifiable, Hashable {
    case male
    case female
    
    static func allValues() -> [String] {
        return [male, female].map({$0.name})
    }
    
    var id: UUID {
        return UUID()
    }
    
    public var name: String {
       switch self {
       case .male:
           return "Male"
       case .female:
           return "Female"
       }
   }
}

enum AccentSelection: Int, CaseIterable, Identifiable, Hashable {
    case english
    case american
    case austrailian
    
    static func allValues() -> [String] {
        return [english, american, austrailian].map({$0.name})
    }
    
    var id: UUID {
        return UUID()
    }
    
    public var name: String {
       switch self {
       case .english:
           return "UK"
       case .american:
           return "US"
    
       case .austrailian:
            return "AUS"
        }
   }
}


class ViewController: UIViewController {
    
//    private var genderSelection: GenderSelection
    
    @IBOutlet weak var genderSelectionSC: UISegmentedControl!
    @IBOutlet weak var accentSelectionSC: UISegmentedControl!
    
    @IBOutlet weak var importBtn: UIButton!
    @IBOutlet weak var generateBtn: UIButton!
    
    @IBOutlet weak var documentView: UIView!
    
    override func viewDidLoad() {
        setUp()
        addValuesToSegmentControls()
    }
    
    public func setUp() {
        documentView.layer.borderWidth = 2
        documentView.layer.borderColor = UIColor.black.cgColor
    
        /* Add appropriate constraints */
//        importBtn.setTitle("Import Text File", for: .normal)
//        generateBtn.setTitle("Generate Audio File", for: .normal)
    }
    
    public func addValuesToSegmentControls() {
        
        //GenderSC
        let male: GenderSelection = .male
        let female: GenderSelection = .female
        
        genderSelectionSC.selectedSegmentIndex = 0;
        
        genderSelectionSC.setTitle(male.name, forSegmentAt: 0)
        genderSelectionSC.setTitle(female.name, forSegmentAt: 1)
        
//        genderSelectionSC.setTitle(GenderSelection.allValues([0]), forSegmentAt: 0)
//        genderSelectionSC.setTitle(GenderSelection.allValues([1]), forSegmentAt: 0)
//        genderSelectionSC = UISegmentedControl(items: GenderSelection.allValues())
        
        
        //AccentSC
        let english: AccentSelection = .english
        let american: AccentSelection = .american
        let austrailian: AccentSelection = .austrailian
        
        accentSelectionSC.selectedSegmentIndex = 0
        
        accentSelectionSC.setTitle(english.name, forSegmentAt: 0)
        accentSelectionSC.setTitle(american.name, forSegmentAt: 1)
        accentSelectionSC.setTitle(austrailian.name, forSegmentAt: 2)
    }
    
    
    @IBAction func importFiles(_ sender: UIButton) {
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText), String(kUTTypeContent), String(kUTTypeImage)], in: .import)
        
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    @IBAction func generateFile(_ sender: Any) {
        print("File Generated!!")
    }
    
}

extension ViewController: UIDocumentPickerDelegate {
    
    private func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt urls: [URL]) {
        /// Handle your document
        
        guard let selectedFileURL = urls.first else {
            return
        }
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            print("Already Exists!")
        } else {
            do {
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
                  print("Success!")
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
}



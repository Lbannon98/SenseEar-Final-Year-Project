//
//  ViewController.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 08/12/2019.
//  Copyright © 2019 Lauren Bannon. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
import MobileCoreServices
import MediaPlayer

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

class ViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var genderSelectionSC: UISegmentedControl!
    @IBOutlet weak var accentSelectionSC: UISegmentedControl!
    
    @IBOutlet weak var importBtn: UIButton!
    @IBOutlet weak var generateBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    
    @IBOutlet weak var genderAudioBtn: CircleButton!
    @IBOutlet weak var accentAudioBtn: CircleButton!
    
    @IBOutlet weak var voiceSelectedGenderLbl: UILabel!
    @IBOutlet weak var voiceSelectedAccentLbl: UILabel!
    
    @IBOutlet weak var documentView: UIView!
    @IBOutlet weak var selectedFileView: SelectedFileView!
    
    //Voice Recognition Variables
    let voiceGenderSelectionDictionary = [
//        "Male": GenderSelection.male,
        "Mail": GenderSelection.male,
        "Female": GenderSelection.female] as [String : Any]
       
   let voiceAccentSelectionDictionary = [
        "English": AccentSelection.english,
        "American": AccentSelection.american,
        "Austrailian": AccentSelection.austrailian] as [String : Any]
    
    var userInputGenderSelection = GenderSelection.female
    var userInputAccentSelection = AccentSelection.austrailian
    let speechRecogniser: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-IRE"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    //File Management Variables
    var filename: String?
    var selectedFile: URL?
    var newConvertedPdf: URL?
    var fileTypeLogo: UIImageView?
    
    //Extracted Text Variable
    var extractedContent: String = ""
    
    //Text to Speech variables
    var genderSelected: String?
    var accentSelected: String?
    static var voiceType: VoiceTypes?
    
    //UIElements
    let microphoneIcon = UIImage(named: "microphone-30.png")
    let stopIcon = UIImage(named: "stop.png")
    
    public var player: AVAudioPlayer?
    public var musicManager: MPMusicPlayerController?
    public var nowPlayingInfo: [String : Any]?
    
    //View Model
    var viewModel: SelectedFileViewModel!

    init(filename: String?, selectedFile: URL?, viewModel: SelectedFileViewModel!) {
        self.filename = filename
        self.selectedFile = selectedFile
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
       super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        setUp()
        addValuesToSegmentControls()
        requestMicrophoneAccess()
    }
    
    public func setUp() {
        documentView.layer.borderWidth = 2
        documentView.layer.borderColor = UIColor.black.cgColor
        
        importBtn.setTitle("Import File", for: .normal)
        
        let cancelConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        clearBtn.setImage(UIImage(systemName: "multiply.circle.fill", withConfiguration: cancelConfiguration), for: .normal)
                
        let tintedImage = microphoneIcon?.withRenderingMode(.alwaysTemplate)
        
        genderAudioBtn.setImage(tintedImage, for: .normal)
        genderAudioBtn.tintColor = .white
        
        accentAudioBtn.setImage(tintedImage, for: .normal)
        accentAudioBtn.tintColor = .white
        
        selectedFileView.isHidden = true
        clearBtn.isHidden = true
    }
    
    public func addValuesToSegmentControls() {
        
        //GenderSC
        genderSelectionSC.selectedSegmentIndex = 0
        
        genderSelectionSC.setTitle(GenderSelection.allValues()[0], forSegmentAt: 0)
        genderSelectionSC.setTitle(GenderSelection.allValues()[1], forSegmentAt: 1)
        
        //AccentSC
        accentSelectionSC.selectedSegmentIndex = 0
        
        accentSelectionSC.setTitle(AccentSelection.allValues()[0], forSegmentAt: 0)
        accentSelectionSC.setTitle(AccentSelection.allValues()[1], forSegmentAt: 1)
        accentSelectionSC.setTitle(AccentSelection.allValues()[2], forSegmentAt: 2)
        
    }
    
    @IBAction func genderSelectionSCChanged(_ sender: Any) {
        
        if genderSelectionSC.selectedSegmentIndex == 0 {
            print(GenderSelection.allValues()[0])
        } else {
            print(GenderSelection.allValues()[1])
        }
        
    }

    @IBAction func accentSelectionSCChanged(_ sender: Any) {
        
        if accentSelectionSC.selectedSegmentIndex == 0 {
            print(AccentSelection.allValues()[0])
        } else if accentSelectionSC.selectedSegmentIndex == 1 {
            print(AccentSelection.allValues()[1])
        } else {
            print(AccentSelection.allValues()[2])
        }
        
    }
    
    @IBAction func genderSpeechSelection(_ sender: Any) {
        
        if audioEngine.isRunning {
            
            audioEngine.stop()
            recognitionRequest?.endAudio()
            genderAudioBtn.isEnabled = false
            
            let tintedImage = microphoneIcon?.withRenderingMode(.alwaysTemplate)
                   
            self.genderAudioBtn.setImage(tintedImage, for: .normal)
            self.genderAudioBtn.tintColor = .white
            
        } else {
            
            self.genderStartRecording()
            
            let tintedImage = stopIcon?.withRenderingMode(.alwaysTemplate)
                   
            self.genderAudioBtn.setImage(tintedImage, for: .normal)
            self.genderAudioBtn.tintColor = .white
            
        }
    
    }
    
    @IBAction func accentSpeechSelection(_ sender: Any) {
        
         if audioEngine.isRunning {
            
            audioEngine.stop()
            recognitionRequest?.endAudio()
            accentAudioBtn.isEnabled = false
            
            let tintedImage = microphoneIcon?.withRenderingMode(.alwaysTemplate)
                   
            self.accentAudioBtn.setImage(tintedImage, for: .normal)
            self.accentAudioBtn.tintColor = .white
                        
        } else {
            
            self.accentStartRecording()
            
            let tintedImage = stopIcon?.withRenderingMode(.alwaysTemplate)
                              
            self.accentAudioBtn.setImage(tintedImage, for: .normal)
            self.accentAudioBtn.tintColor = .white

        }
        
    }
    
    @IBAction func importFiles(_ sender: UIButton) {
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText), String(kUTTypePlainText), String(kUTTypeContent)], in: .import)

        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
            
    }
    
    @IBAction func clearFileSelection(_ sender: Any) {
        
        viewModel = SelectedFileViewModel(filename: filename!, fileTypeLogo: fileTypeLogo!)
        selectedFileView.clear(with: viewModel)
        
        selectedFileView.isHidden = true
        clearBtn.isHidden = true
        
        print("Cleared selected file, select another!")
        
    }
    
    @IBAction func generateFile(_ sender: Any) {
        
        generateBtn.setTitle("Generating...", for: .normal)
//        generateBtn.isEnabled = false
        
        ViewController.voiceType = .undefined
        
        genderSelected = genderSelectionSC.titleForSegment(at: genderSelectionSC.selectedSegmentIndex)
        
        accentSelected = accentSelectionSC.titleForSegment(at: accentSelectionSC.selectedSegmentIndex)
        
        if genderSelected == "Male" && accentSelected == "UK" {

            ViewController.voiceType = .ukMale
            
        } else if genderSelected == "Male" && accentSelected == "US" {
                   
           ViewController.voiceType = .usMale
            
        } else if genderSelected == "Male" && accentSelected == "AUS" {
                   
           ViewController.voiceType = .ausMale
           
        } else if genderSelected == "Female" && accentSelected == "UK" {
                    
            ViewController.voiceType = .ukFemale
            
        } else if genderSelected == "Female" && accentSelected == "US" {
                    
            ViewController.voiceType = .usFemale
            
        } else if genderSelected == "Female" && accentSelected == "AUS" {
                    
            ViewController.voiceType = .ausFemale
            
        }
        
        TextToSpeechService.shared.makeTextToSpeechRequest(text: extractedContent, voiceType: ViewController.voiceType!) {

            self.generateBtn.setTitle("File Generated", for: .normal)
            self.generateBtn.isEnabled = true

        }

    }
    
}




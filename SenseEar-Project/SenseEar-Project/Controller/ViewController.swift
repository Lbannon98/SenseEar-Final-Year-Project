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
import Dispatch

enum GenderSelection: Int, CaseIterable, Identifiable, Hashable {
    case male
    case female
    case clear
    
    static func allValues() -> [String] {
        return [male, female, clear].map({$0.name})
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
       case .clear:
            return ""
        }
   }
}

enum AccentSelection: Int, CaseIterable, Identifiable, Hashable {
    case english
    case american
    case austrailian
    case clear
    
    static func allValues() -> [String] {
        return [english, american, austrailian, clear].map({$0.name})
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
       case .clear:
            return ""
        }
   }
}

class ViewController: UIViewController, SFSpeechRecognizerDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var genderSelectionSC: UISegmentedControl!
    @IBOutlet weak var accentSelectionSC: UISegmentedControl!
    
    @IBOutlet weak var importBtn: UIButton!
    @IBOutlet weak var playPauseAudioBtn: UIButton!
    @IBOutlet weak var replayBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var generateAudioBtn: UIButton!
    
    @IBOutlet weak var genderAudioBtn: CircleButton!
    @IBOutlet weak var accentAudioBtn: CircleButton!
    
    @IBOutlet weak var voiceSelectedGenderLbl: UILabel!
    @IBOutlet weak var voiceSelectedAccentLbl: UILabel!
    
    @IBOutlet weak var documentView: UIView!
    @IBOutlet weak var selectedFileView: SelectedFileView!
    
    //Voice Recognition Variables
    let voiceGenderSelectionDictionary = [
        "Mail": GenderSelection.male,
        "Female": GenderSelection.female,
        "Remove": GenderSelection.clear] as [String : Any]
       
   let voiceAccentSelectionDictionary = [
        "UK": AccentSelection.english,
        "US": AccentSelection.american,
        "AUS": AccentSelection.austrailian,
        "Remove": AccentSelection.clear] as [String : Any]

    let speechRecogniser: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.current)
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
    
    //Media Player Variables
    var isPaused = false
    var isPlaying = false
    var extractedAudio = Data()
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
        
        importBtn.setTitle("Upload File", for: .normal)
        
        let cancelConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
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
    
    public func assignAudioSpecifications() {
        
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
            
        } else {
            
            Alerts.showStandardAlert(on: self, with: "Try Again", message: "Audio specifications did not assign correctly!")
            
        }
        
    }
    
//    func updatePlayerIcons() {
//
//        if AudioPlayer.isPaused == false {
//
//            let playConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
//            playPauseAudioBtn.setImage(UIImage(systemName: "play", withConfiguration: playConfiguration), for: .normal)
//
//        } else {
//
//            let pauseConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
//            playPauseAudioBtn.setImage(UIImage(systemName: "pause", withConfiguration: pauseConfiguration), for: .normal)
//
//        }
//
//    }
    
    func getAudioData() -> Data {
        
        guard let audio = TextToSpeechService.audioData else { fatalError("Couldn't get audio data") }
        extractedAudio = audio
        
        return extractedAudio
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
        
        generateAudioBtn.setTitle("Generate Audio", for: .normal)
        generateAudioBtn.isEnabled = true
        
        TextToSpeechService.audioPlayer.resetAudioData()
        
        print("Cleared selected file, select another!")
        
    }
    
    @IBAction func generateAudio(_ sender: Any) {
        
        if selectedFile == nil {
            
            Alerts.showStandardAlert(on: self, with: "Upload File", message: "File has not been selected, there is nothing to generate")
            
        } else {
            
            assignAudioSpecifications()
            
            TextToSpeechService.shared.makeTextToSpeechRequest(text: self.extractedContent, voiceType: ViewController.voiceType!) {
                                                                
            }
                                            
            sleep(3)
            
            TextToSpeechService.audioPlayer.getAudioData()
                    
            generateAudioBtn.setTitle("Audio Generated", for: .normal)
            generateAudioBtn.isEnabled = false
            
        }
        
    }
    
    @IBAction func playPauseAudio(_ sender: Any) {
        
        if selectedFile == nil {
            
            Alerts.showStandardAlert(on: self, with: "Upload File", message: "File has not been selected, so there is no audio")
            
        } else {
            
             guard let player = TextToSpeechService.audioPlayer.player else { return }
                
            player.delegate = self
            
            if isPlaying {
                                
                player.pause()

                isPlaying = false
                isPaused = true

                let playConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
                playPauseAudioBtn.setImage(UIImage(systemName: "play", withConfiguration: playConfiguration), for: .normal)

            } else {
                                
                player.play()

                isPlaying = true
                isPaused = false

                let pauseConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
                playPauseAudioBtn.setImage(UIImage(systemName: "pause", withConfiguration: pauseConfiguration), for: .normal)

            }
            
        }

    }
    
    @IBAction func replayAudio(_ sender: Any) {
        
        if selectedFile == nil {
            
            Alerts.showStandardAlert(on: self, with: "Upload File", message: "File has not been selected, so there is no audio")
            
        } else {
        
            guard let player = TextToSpeechService.audioPlayer.player else { return }
            
            player.stop()
            player.currentTime = 0
            isPlaying = false
            
        }
    }
     
}




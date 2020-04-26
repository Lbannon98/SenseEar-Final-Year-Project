//
//  ViewController.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 08/12/2019.
//  Copyright © 2019 Lauren Bannon. All rights reserved.
//

import Foundation
import UIKit
import Speech
import MobileCoreServices
import AVFoundation
import MediaPlayer
import FirebaseDatabase
import FirebaseStorage

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
    case uk
    case us
    case aus
    case clear
    
    static func allValues() -> [String] {
        return [uk, us, aus, clear].map({$0.name})
    }
    
    var id: UUID {
        return UUID()
    }
    
    public var name: String {
       switch self {
       case .uk:
            return "UK"
       case .us:
            return "US"
       case .aus:
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
        "UK": AccentSelection.uk,
        "US": AccentSelection.us,
        "AUS": AccentSelection.aus,
        "Remove": AccentSelection.clear] as [String : Any]

    let speechRecogniser: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.current)
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    //File Management Variables
    public static var filename: String?
    public static var selectedFile: URL?
    var newConvertedPdf: URL?
    public static var fileTypeLogo: UIImageView?
    
    //Extracted Text Variable
    var extractedContent: String = ""
    
    //Text to Speech variables
    var genderSelected: String?
    var accentSelected: String?
    static var voiceType: VoiceTypes?
    
    //UIElements
    let microphoneIcon = UIImage(named: "microphone-30.png")
    let stopIcon = UIImage(named: "stop.png")
    let iconConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
    
    //Media Player Variables
    public var musicManager: MPMusicPlayerController?
    public var nowPlayingInfo: [String : Any]?
    var isPaused = false
    var isPlaying = false
    
    //History Variables
    public static var firebaseDBRef = Database.database().reference()
    public var time: String?
    public static var historyFilename: String?
    public static var historyTime: String?
    public static var historyImage: UIImage?
    var selectedFileStack: [HistoryDataSource] = []
    var firbaseDBHandle: DatabaseHandle?
    var sortingTimeStamp: [Date] = []
    
    //View Model
    var viewModel: SelectedFileViewModel!

    init(filename: String?, selectedFile: URL?, viewModel: SelectedFileViewModel!) {
        ViewController.filename = filename
        ViewController.selectedFile = selectedFile
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
        documentView.layer.cornerRadius = 20
        documentView.layer.borderColor = UIColor.black.cgColor
        
        importBtn.setTitle("Upload File", for: .normal)
        
        clearBtn.setImage(UIImage(systemName: "multiply.circle.fill", withConfiguration: iconConfiguration), for: .normal)
                
        let tintedImage = microphoneIcon?.withRenderingMode(.alwaysTemplate)
        
        genderAudioBtn.setImage(tintedImage, for: .normal)
        genderAudioBtn.tintColor = .white
        
        accentAudioBtn.setImage(tintedImage, for: .normal)
        accentAudioBtn.tintColor = .white
        
        selectedFileView.isHidden = true
        clearBtn.isHidden = true
        
        generateAudioBtn.setTitle("Generate Audio", for: .normal)
        
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
    
    func writeHistoryDatatoFirebase() {
        
        ViewController.firebaseDBRef.child("history-data/\(UUID().uuidString)").setValue([
            
            "filename" : ViewController.filename!,
            "time" : time!
        
        ])
        
    }
    
    func setHistoryFileImage() {
             
        if ViewController.historyFilename?.contains("txt") == true {

            ViewController.historyImage = UIImage(named: "text-file-50.png")

      } else if ViewController.historyFilename?.contains("pdf") == true {

            ViewController.historyImage = UIImage(named: "icons8-pdf-48-2.png")

      } else if ViewController.historyFilename?.contains("docx") == true {

            ViewController.historyImage = UIImage(named: "icons8-microsoft-word-48.png")

      } else if ViewController.historyFilename?.contains("xlsx") == true {

            ViewController.historyImage = UIImage(named: "icons8-microsoft-excel-48.png")
          
      } else if ViewController.historyFilename?.contains("pptx") == true {

            ViewController.historyImage = UIImage(named: "icons8-microsoft-powerpoint-48.png")

      }
      
    }
    
    public func readingHistoryDataFromFirebase() {
                
        firbaseDBHandle = ViewController.firebaseDBRef.child("history-data").observe(.childAdded) { (snapshot) in
            
            let data = snapshot.value as? [String : AnyObject] ?? [:]
            
            ViewController.historyTime = data["time"]! as? String
            ViewController.historyFilename = data["filename"]! as? String
            
            self.setHistoryFileImage()
            
            self.selectedFileStack = [HistoryDataSource(image: ViewController.historyImage!, name: ViewController.historyFilename!, time: ViewController.historyTime!)]
            
            HistoryViewController.arrayData.append(contentsOf: self.selectedFileStack)
        
        }
        
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
        
        generateAudioBtn.isEnabled = true
            
    }
    
    @IBAction func clearFileSelection(_ sender: Any) {
        
        viewModel = SelectedFileViewModel(filename: ViewController.filename!, fileTypeLogo: ViewController.fileTypeLogo!)
        selectedFileView.clear(with: viewModel)
        
        selectedFileView.isHidden = true
        clearBtn.isHidden = true
        
        ViewController.selectedFile = nil
        
        generateAudioBtn.setTitle("Generate Audio", for: .normal)
        generateAudioBtn.isEnabled = false
        
        voiceSelectedGenderLbl.text = nil
        voiceSelectedAccentLbl.text = nil
        
        TextToSpeechService.audioPlayer.resetAudioData()
        
        playPauseAudioBtn.setImage(UIImage(systemName: "play", withConfiguration: iconConfiguration), for: .normal)
        
        print("Cleared selected file, select another!")
        
    }
    
    @IBAction func generateAudio(_ sender: Any) {
                
        if ViewController.selectedFile == nil {
            
            Alerts.showStandardAlert(on: self, with: "Upload File", message: "File has not been selected, there is nothing to generate")
            
        } else {

            generateAudioBtn.isEnabled = false
            
            assignAudioSpecifications()
            
            TextToSpeechService.shared.makeTextToSpeechRequest(text: self.extractedContent, voiceType: ViewController.voiceType!) {}
                       
            if TextDivider.characterCount! <= 5000 {
                
                sleep(12)
                
            } else if TextDivider.characterCount! > 5000 && TextDivider.characterCount! <= 10000 {
            
                sleep(18)
                
            } else {
                
                sleep(22)
                
            }
            
            TextToSpeechService.audioPlayer.getAudioData()
            
            self.setupRemoteTransportControls()
            self.setupNotificationView()

            let date = Date()
            time = date.formatTime(format: "MM-dd-yyyy HH:mm")
                         
            HistoryViewController.arrayData.append(contentsOf: selectedFileStack)
           
            self.writeHistoryDatatoFirebase()
            
            generateAudioBtn.setTitle("Audio Generated", for: .normal)
            
        }
        
    }
    
    @IBAction func playPauseAudio(_ sender: Any) {
        
        if ViewController.selectedFile == nil && AudioPlayer.extractedAudio == nil {
            
            Alerts.showStandardAlert(on: self, with: "Upload File", message: "File has not been selected, so there is no audio")
            
        } else if ViewController.selectedFile != nil && AudioPlayer.extractedAudio == nil {
            
             Alerts.showStandardAlert(on: self, with: "Generate Audio", message: "File has been selected, but audio needs to be generated, press Generate Audio")
            
        } else {
            
            guard let player = TextToSpeechService.audioPlayer.player else { return }
                
            player.delegate = self
            
            if isPlaying {
                                
                player.pause()
                
                self.updateNowPlaying(isPause: true)

                isPlaying = false
                isPaused = true

                playPauseAudioBtn.setImage(UIImage(systemName: "play", withConfiguration: iconConfiguration), for: .normal)

            } else {
                                
                player.play()
                
                self.updateNowPlaying(isPause: false)

                isPlaying = true
                isPaused = false

                playPauseAudioBtn.setImage(UIImage(systemName: "pause", withConfiguration: iconConfiguration), for: .normal)

            }
            
        }

    }
    
    @IBAction func replayAudio(_ sender: Any) {
        
        if ViewController.selectedFile == nil && AudioPlayer.extractedAudio == nil {
            
            Alerts.showStandardAlert(on: self, with: "Upload File", message: "File has not been selected, and no audio was generated")
            
        } else if ViewController.selectedFile != nil && AudioPlayer.extractedAudio == nil {
            
             Alerts.showStandardAlert(on: self, with: "Generate Audio", message: "File has been selected, but audio needs to be generated, press Generate Audio")
            
        } else {
        
            guard let player = TextToSpeechService.audioPlayer.player else { return }
            
            player.stop()
            player.currentTime = 0
            isPlaying = false
            
            playPauseAudioBtn.setImage(UIImage(systemName: "play", withConfiguration: iconConfiguration), for: .normal)
            
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

        playPauseAudioBtn.setImage(UIImage(systemName: "play", withConfiguration: iconConfiguration), for: .normal)

    }
     
}

extension Date {
    
    func formatTime(format: String) -> String {
        
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        
        return dateformat.string(from: self)
        
    }
    
}



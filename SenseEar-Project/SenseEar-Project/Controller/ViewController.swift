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
    
//    private var genderSelection: GenderSelection
    
    @IBOutlet weak var genderSelectionSC: UISegmentedControl!
    @IBOutlet weak var accentSelectionSC: UISegmentedControl!
    
    @IBOutlet weak var importBtn: UIButton!
    @IBOutlet weak var generateBtn: UIButton!
    
    @IBOutlet weak var genderAudioBtn: CircleButton!
    @IBOutlet weak var accentAudioBtn: CircleButton!
    
    @IBOutlet weak var voiceSelectedGenderLbl: UILabel!
    @IBOutlet weak var voiceSelectedAccentLbl: UILabel!
    
    @IBOutlet weak var documentView: UIView!
    
    var userInputGenderSelection = GenderSelection.female
    let speechRecogniser: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-UK"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    override func viewDidLoad() {
        setUp()
        addValuesToSegmentControls()
        
        requestMicrophoneAccess()
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
    
    func requestMicrophoneAccess() {
        speechRecogniser?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization {
            status in
            var buttonState = false
            switch status {
            case .authorized:
                buttonState = true
                print("Permission received")
            case .denied:
                buttonState = false
                print("User did not give permission to use speech recognition")
            case .notDetermined:
                buttonState = false
                print("Speech recognition not allowed by user")
            case .restricted:
                buttonState = false
                print("Speech recognition not supported on this device")
            }
            DispatchQueue.main.async {
                self.voiceSelectedGenderLbl.isEnabled = buttonState
            }
        }
        self.voiceSelectedGenderLbl.frame.size.width = view.bounds.width - 64
    }
    
    func startRecording() {
        if recognitionTask != nil { //created when request kicked off by the recognizer. used to track progress of a transcription or cancel it
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.record)), mode: .default)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup audio session")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest() //read from buffer
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Could not create request instance")
        }
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecogniser?.recognitionTask(with: recognitionRequest) {
            res, err in
            var isLast = false
            if res != nil { //res contains transcription of a chunk of audio, corresponding to a single word usually
                isLast = (res?.isFinal)!
            }
            
            if err != nil || isLast {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.genderAudioBtn.isEnabled = true
                let bestStr = res?.bestTranscription.formattedString
                var inDict = self.voiceGenderSelectionDictionary.contains { $0.key == bestStr}
                
                if inDict {
                    self.voiceSelectedGenderLbl.text = bestStr
                    self.userInputGenderSelection = self.voiceGenderSelectionDictionary[bestStr!]! as! GenderSelection
                }
                else {
                    self.voiceSelectedGenderLbl.text = "Can't find it in the dictionary"
//                    self.userInputGenderSelection = GenderSelection.male
                }
//                self.mapSetUp()
            }
            
        }
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) {
            buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("Can't start the engine")
        }
    }

    @IBAction func genderSpeechSelection(_ sender: Any) {
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            genderAudioBtn.isEnabled = false
            self.self.genderAudioBtn.setTitle("Record", for: .normal)
//            if let image = UIImage(named: "microphone-30.png") {
//                self.genderAudioBtn.setImage(image, for: .normal)
//            }
//            self.genderAudioBtn.setTitle("Record", for: .normal)
        } else {
            startRecording()
            genderAudioBtn.setTitle("Stop", for: .normal)

//            if let image = UIImage(named: "stop.circle.fill.png") {
//                self.genderAudioBtn.setImage(image, for: .normal)
//            }
//            self.genderAudioBtn.setTitle("Stop", for: .normal)
        }
            
        print("Gender Selected!")
    }
    
    
    @IBAction func accentSpeechSelection(_ sender: Any) {
        print("Accent Selected!")
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
    
    let voiceGenderSelectionDictionary = [
        "Male": GenderSelection.male,
        "Female": GenderSelection.female] as [String : Any]
    
    let voiceAccentSelectionDictionary = [
        "English": AccentSelection.english,
        "American": AccentSelection.american,
        "Austrailian": AccentSelection.austrailian] as [String : Any]
    
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

fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
        return input.rawValue
}

//extension ViewController: SFSpeechRecognizerDelegate {
//
//
//}



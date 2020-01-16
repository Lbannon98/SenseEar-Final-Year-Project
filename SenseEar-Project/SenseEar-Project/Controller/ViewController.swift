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
import FirebaseStorage

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
    
    @IBOutlet weak var genderAudioBtn: CircleButton!
    @IBOutlet weak var accentAudioBtn: CircleButton!
    
    @IBOutlet weak var voiceSelectedGenderLbl: UILabel!
    @IBOutlet weak var voiceSelectedAccentLbl: UILabel!
    
    @IBOutlet weak var documentView: UIView!
    
    var firebaseStorageReference: StorageReference {
        return Storage.storage().reference().child("documents")
    }
    
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

    override func viewDidLoad() {
        setUp()
        addValuesToSegmentControls()
        requestMicrophoneAccess()
    }
    
    public func setUp() {
        documentView.layer.borderWidth = 2
        documentView.layer.borderColor = UIColor.black.cgColor
        
        genderAudioBtn.setImage(UIImage(named: "microphone-30.png"), for: .normal)
        accentAudioBtn.setImage(UIImage(named: "microphone-30.png"), for: .normal)
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
    
    func requestMicrophoneAccess() {
        speechRecogniser?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization {
            authenticationStatus in
            var buttonState = false
            
            switch authenticationStatus {
            case .authorized:
                buttonState = true
                print("Permission received!")
                
            case .denied:
                buttonState = false
                print("User did not give permission to use speech recognition!")
                
            case .notDetermined:
                buttonState = false
                print("Speech recognition not allowed by user!")
                
            case .restricted:
                buttonState = false
                print("Speech recognition not supported on this device!")
                
            @unknown default:
                fatalError()
            }
            
            DispatchQueue.main.async {
                self.voiceSelectedGenderLbl.isEnabled = buttonState
                self.voiceSelectedAccentLbl.isEnabled = buttonState
            }
        }
        self.voiceSelectedGenderLbl.frame.size.width = view.bounds.width - 64
        self.voiceSelectedAccentLbl.frame.size.width = view.bounds.width - 64

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
    
    
    func genderStartRecording() {
        if recognitionTask != nil {
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
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Could not create request instance")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecogniser?.recognitionTask(with: recognitionRequest) {

            result, error in
            var isLast = false
            if result != nil {
                isLast = (result?.isFinal)!
            }
            
            if error != nil || isLast {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.genderAudioBtn.isEnabled = true
                
                let bestTranscription = result?.bestTranscription.formattedString
                var inGenderSelectionDictionary = self.voiceGenderSelectionDictionary.contains { $0.key == bestTranscription}
                
                if inGenderSelectionDictionary {
                    
                    self.voiceSelectedGenderLbl.text = bestTranscription
                    self.userInputGenderSelection = self.voiceGenderSelectionDictionary[bestTranscription!]! as! GenderSelection
                    
                } else {
                    self.voiceSelectedGenderLbl.text = "Not understood, try again"
                }
    
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
    
    func accentStartRecording() {
        if recognitionTask != nil {
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
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Could not create request instance")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecogniser?.recognitionTask(with: recognitionRequest) {

            result, error in
            var isLast = false
            if result != nil {
                isLast = (result?.isFinal)!
            }
            
            if error != nil || isLast {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.accentAudioBtn.isEnabled = true
                
                let bestTranscription = result?.bestTranscription.formattedString
                var inAccentSelectionDictionary = self.voiceAccentSelectionDictionary.contains {$0.key == bestTranscription}
                
                if inAccentSelectionDictionary {
                    
                    self.voiceSelectedAccentLbl.text = bestTranscription
                    self.userInputAccentSelection = self.voiceAccentSelectionDictionary[bestTranscription!]! as! AccentSelection
                    
                } else {
                    self.voiceSelectedAccentLbl.text = "Not understood, try again"
                }
                
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
            self.genderAudioBtn.setImage(UIImage(named: "microphone-30.png"), for: .normal)

        } else {
            
            genderStartRecording()
            self.genderAudioBtn.setImage(UIImage(named: "stop.png"), for: .normal)

        }
    
    }
    
    
    @IBAction func accentSpeechSelection(_ sender: Any) {
        
         if audioEngine.isRunning {
            
            audioEngine.stop()
            recognitionRequest?.endAudio()
            accentAudioBtn.isEnabled = false
            self.accentAudioBtn.setImage(UIImage(named: "microphone-30.png"), for: .normal)
            
        } else {
            
            accentStartRecording()
            self.accentAudioBtn.setImage(UIImage(named: "stop.png"), for: .normal)

        }
        
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
        /// Handle your document
        
        guard let selectedFileURL = urls.first else {
            return
        }
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
        let uploadDocumentRef = firebaseStorageReference.child(sandboxFileURL.absoluteString)
        
        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            print("Already Exists!")
        } else {
            do {
                let contents = try FileManager.default.contents(atPath: sandboxFileURL.absoluteString)
                
                let uploadTask = uploadDocumentRef.putData(contents!, metadata: nil) { (metadata, error) in
                    print("Upload Task Finished")
                    print(metadata ?? "No Metadata")
                    print(error ?? "No Error")
                }
                uploadTask.resume()
            }
            
        }
    }
    
}

fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
        return input.rawValue
}



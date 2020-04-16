//
//  VoiceController + VoiceRecognition.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 22/01/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import Foundation
import Speech
import UIKit

extension ViewController {
        
    /// Sets up microphone access request to user
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
    
    /// Starts recording for the gender selection voice recogntion
      func genderStartRecording() {
        
          if recognitionTask != nil {
              recognitionTask?.cancel()
              recognitionTask = nil
          }
        
          let audioSession = AVAudioSession.sharedInstance()
        
          do {
              
                try audioSession.setCategory(.record, mode: .default)
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
                  let inGenderSelectionDictionary = self.voiceGenderSelectionDictionary.contains { $0.key == bestTranscription}
                  
                  if inGenderSelectionDictionary {
                    
                    if bestTranscription == "Mail" {
                        
                        self.voiceSelectedGenderLbl.text = "Male"
                        self.genderSelectionSC.selectedSegmentIndex = 0
                        
                    } else if bestTranscription == "Remove" {
                        
                        self.voiceSelectedGenderLbl.text = ""
                        self.genderSelectionSC.selectedSegmentIndex = 0
                        
                    } else {
                        
                        self.voiceSelectedGenderLbl.text = bestTranscription
                        self.genderSelectionSC.selectedSegmentIndex = 1

                    }

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
      
    /// Starts recording for the accent selection voice recogntion
      func accentStartRecording() {
        
          if recognitionTask != nil {
              recognitionTask?.cancel()
              recognitionTask = nil
          }
        
          let audioSession = AVAudioSession.sharedInstance()
        
          do {
              
                try audioSession.setCategory(.record, mode: .default)
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
                  let inAccentSelectionDictionary = self.voiceAccentSelectionDictionary.contains {$0.key == bestTranscription}
                  
                  if inAccentSelectionDictionary {
                    
                    if bestTranscription == "UK" {
                        
                        self.accentSelectionSC.selectedSegmentIndex = 0
                        self.voiceSelectedAccentLbl.text = bestTranscription
                        
                        
                    } else if bestTranscription == "US" {
                        
                        self.accentSelectionSC.selectedSegmentIndex = 1
                        self.voiceSelectedAccentLbl.text = bestTranscription

                        
                    } else if bestTranscription == "AUS" {
                        
                        self.accentSelectionSC.selectedSegmentIndex = 2
                        self.voiceSelectedAccentLbl.text = bestTranscription

                    } else {
                        
                        self.accentSelectionSC.selectedSegmentIndex = 0
                        self.voiceSelectedAccentLbl.text = ""
                        
                    }
                      
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
    
}

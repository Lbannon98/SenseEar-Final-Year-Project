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
    
}

fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
        return input.rawValue
}


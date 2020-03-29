//
//  TextToSpeechService.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 29/03/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import UIKit
import Foundation
//import AudioToolbox
import AVFoundation


enum VoiceTypes: String {
    
    case undefined
    case ukFemale = "en-GB-Wavenet-A"
    case ukMale = "en-GB-Wavenet-B"
    case usFemale = "en-US-Wavenet-C"
    case usMale = "en-US-Wavenet-D"
    case ausFemale = "en-AU-Wavenet-C"
    case ausMale = "en-AU-Wavenet-D"
    
}

//enum LanguageCodes: String {
//
//    case undefined
//    case ukCode = "en-GB"
//    case usCode = "en-US"
//    case ausCode = "en-AU"
//
//}

let ttsPostAPIUrl = "https://texttospeech.googleapis.com/v1/text:synthesize"
//let APIKey = "AIzaSyAJBTvp9M-P0owWFvh61C4zk4GgpLB4Upk"
let APIKey = valueForAPIKey(named:"GOOGLE_TTS_API_KEY")

class TextToSpeechService: NSObject, AVAudioPlayerDelegate {
    
    static let shared = TextToSpeechService()
    
    private var player: AVAudioPlayer?
    private var completionHandler: (() -> Void)?
    
    func writeAudioToFile(text: String, voiceType: VoiceTypes = .ukMale, completion: @escaping () -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
           let postData = self.buildPostRequest(text: text, voiceType: voiceType)
           let headers = ["X-Goog-Api-Key": APIKey, "Content-Type": "application/json; charset=utf-8"]
           let response = self.makePostRequest(url: ttsPostAPIUrl, postData: postData, headers: headers)

           // Get the `audioContent` (as a base64 encoded string) from the response.
           guard let audioContent = response["audioContent"] as? String else {
            
               print("Invalid response: \(response)")
    //               self.busy = false
            
               DispatchQueue.main.async {
                   completion()
               }
               return
           }
           
           // Decode the base64 string into a Data object
           guard let audioData = Data(base64Encoded: audioContent) else {
            
    //               self.busy = false
               DispatchQueue.main.async {
                   completion()
               }
               return
           }
            
            DispatchQueue.main.async {
                
                self.completionHandler = completion
                self.player = try! AVAudioPlayer(data: audioData)
                self.player?.delegate = self
                self.player!.play()
            }
            
//            do {
//
//                let filePath = FileManager.default.currentDirectoryPath
//
//                let url = URL(fileURLWithPath: filePath)
//
//                try audioData.write(to: url, options: .atomic)
//
//            } catch {
//
//                print(error)
//
//            }
            
            
            
            
            
//            var audioFile:audioFile
//            var audioErr:OSStatus = noErr
//            audioErr = AudioFileCreateWithURL(fileURL,                  // 9
//                                              AudioFileTypeID(kAudioFileAIFFType),
//                                              &asbd,
//                                              .EraseFile,
//                                              &audioFile)
           
//           DispatchQueue.main.async {
//               self.completionHandler = completion
//               self.player = try! AVAudioPlayer(data: audioData)
//               self.player?.delegate = self
//               self.player!.play()
//           }
            
       }
        
    }
    
    private func buildPostRequest(text: String, voiceType: VoiceTypes) -> Data {
        
//        let type = ViewController.voiceType!.rawValue
//
//        let languageCode = String(type.prefix(4))

        var voiceConfig: [String: Any] = [
            "languageCode": "en-UK"
//            languageCode
        ]
        
        if voiceType != .undefined {
            voiceConfig["name"] = voiceType.rawValue
        }
        
        let parameters: [String: Any] = [
            "input": [
                "text": text
            ],
            "voice": voiceConfig,
            "audioConfig": [
                "audioEncoding": "LINEAR16"
            ]
        ]

        // Convert the Dictionary to Data
        let data = try! JSONSerialization.data(withJSONObject: parameters)
        return data
    }
    
    // Make POST request
    private func makePostRequest(url: String, postData: Data, headers: [String: String] = [:]) -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = postData

        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // Using semaphore to make request synchronous
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                dict = json
            }
            
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return dict
    }
    
//    // Implement AVAudioPlayerDelegate "did finish" callback to cleanup and notify listener of completion.
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        self.player?.delegate = nil
//        self.player = nil
//        self.busy = false
//
//        self.completionHandler!()
//        self.completionHandler = nil
//    }
    
}

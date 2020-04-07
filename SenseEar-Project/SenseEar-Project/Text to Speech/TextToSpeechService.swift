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
            
//            let postData = self.buildPostRequest(firstHalf: TextBuffer.firstHalfOfContents, secondHalf: TextBuffer.secondHalfOfContents, voiceType: voiceType)
//            let postData = self.buildPostRequestFirstHalf(firstHalf: TextBuffer.firstHalfOfContents, voiceType: voiceType)
            let postData = self.buildPostRequest(text: text, firstHalf: TextBuffer.firstHalfOfContents, secondHalf: TextBuffer.secondHalfOfContents, voiceType: voiceType)
           let headers = ["X-Goog-Api-Key": APIKey, "Content-Type": "application/json; charset=utf-8"]
            let response = self.makePostRequest(url: ttsPostAPIUrl, text: postData[0], firstHalfOfPostData: postData[1], secondHalfOfPostData: postData[2], headers: headers)
//           let response = self.makePostRequest(url: ttsPostAPIUrl, postData: postData, headers: headers)

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
    
    private func buildPostRequest(text: String, firstHalf: String, secondHalf: String, voiceType: VoiceTypes) -> [Data] {
        
        var data:[Data] = []
        
        var voiceConfig: [String: Any] = [
            "languageCode": "en-UK"
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
        
        let firstHalfParameters: [String: Any] = [
            "input": [
                "text": firstHalf
            ],
            "voice": voiceConfig,
            "audioConfig": [
                "audioEncoding": "LINEAR16"
            ]
        ]
        
        let secondHalfParameters: [String: Any] = [
            "input": [
                "text": secondHalf
            ],
            "voice": voiceConfig,
            "audioConfig": [
                "audioEncoding": "LINEAR16"
            ]
        ]

        // Convert the Dictionary to Data
        let regualrData = try! JSONSerialization.data(withJSONObject: parameters)
        let firstHalfData = try! JSONSerialization.data(withJSONObject: firstHalfParameters)
        let secondHalfData = try! JSONSerialization.data(withJSONObject: secondHalfParameters)
        
        data.append(regualrData)
        data.append(firstHalfData)
        data.append(secondHalfData)
        
        return data
    }
    
    private func makePostRequest(url: String, text: Data, firstHalfOfPostData: Data, secondHalfOfPostData: Data, headers: [String: String] = [:]) -> [String: AnyObject] {
        
        var dict: [String: AnyObject] = [:]
        
        //Regular Request
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = text

        //First Half Request
        var firstHalfRequest = URLRequest(url: URL(string: url)!)
        firstHalfRequest.httpMethod = "POST"
        firstHalfRequest.httpBody = firstHalfOfPostData
        
        //First Half Request
        var secondHalfRequest = URLRequest(url: URL(string: url)!)
        secondHalfRequest.httpMethod = "POST"
        secondHalfRequest.httpBody = secondHalfOfPostData

        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
            firstHalfRequest.addValue(header.value, forHTTPHeaderField: header.key)
            secondHalfRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // Using semaphore to make request synchronous
        let semaphore = DispatchSemaphore(value: 0)

        let regularTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                dict = json
            }

            semaphore.signal()
        }
        
        let firstHalfTask = URLSession.shared.dataTask(with: firstHalfRequest) { data, response, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                dict = json
            }

            semaphore.signal()
        }
        
        let secondHalfTask = URLSession.shared.dataTask(with: secondHalfRequest) { data, response, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                dict = json
            }

            semaphore.signal()
        }

        regularTask.resume()
        firstHalfTask.resume()
        secondHalfTask.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        return dict
    }
    
//    private func buildPostRequestSecondHalf(secondHalf: String, voiceType: VoiceTypes) -> Data {
//
//        var voiceConfig: [String: Any] = [
//            "languageCode": "en-UK"
//        ]
//
//        if voiceType != .undefined {
//            voiceConfig["name"] = voiceType.rawValue
//        }
//
//        let parameters: [String: Any] = [
//            "input": [
//                "text": secondHalf
//            ],
//            "voice": voiceConfig,
//            "audioConfig": [
//                "audioEncoding": "LINEAR16"
//            ]
//        ]
//
//        // Convert the Dictionary to Data
//        let data = try! JSONSerialization.data(withJSONObject: parameters)
//        return data
//    }
    
//    private func makePostRequestFirstHalf(url: String, postData: Data, headers: [String: String] = [:]) -> [String: AnyObject] {
//        var dict: [String: AnyObject] = [:]
//
//        var request = URLRequest(url: URL(string: url)!)
//        request.httpMethod = "POST"
//        request.httpBody = firstHalfOfPostData
//
//        for header in headers {
//            request.addValue(header.value, forHTTPHeaderField: header.key)
//        }
//
//        // Using semaphore to make request synchronous
//        let semaphore = DispatchSemaphore(value: 0)
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
//                dict = json
//            }
//
//            semaphore.signal()
//        }
//
//        task.resume()
//        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
//
//        return dict
//    }
//
//    private func makePostRequestSecondHalf(url: String, secondHalfOfPostData: Data, headers: [String: String] = [:]) -> [String: AnyObject] {
//        var dict: [String: AnyObject] = [:]
//
//        var request = URLRequest(url: URL(string: url)!)
//        request.httpMethod = "POST"
//        request.httpBody = secondHalfOfPostData
//
//        for header in headers {
//            request.addValue(header.value, forHTTPHeaderField: header.key)
//        }
//
//        // Using semaphore to make request synchronous
//        let semaphore = DispatchSemaphore(value: 0)
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
//                dict = json
//            }
//
//            semaphore.signal()
//        }
//
//        task.resume()
//        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
//
//        return dict
//    }
    
//    private func buildPostRequest(firstHalf: String, secondHalf: String, voiceType: VoiceTypes) -> Data {
//
//        var voiceConfig: [String: Any] = [
//            "languageCode": "en-UK"
//        ]
//
//        if voiceType != .undefined {
//            voiceConfig["name"] = voiceType.rawValue
//        }
//
//        let parameters: [String: Any] = [
//            "input": [
//                "text": firstHalf + secondHalf
//            ],
//            "voice": voiceConfig,
//            "audioConfig": [
//                "audioEncoding": "LINEAR16"
//            ]
//        ]
//
//        // Convert the Dictionary to Data
//        let data = try! JSONSerialization.data(withJSONObject: parameters)
//        return data
//    }
    
//     Make POST request
//    private func makePostRequest(url: String, firstHalfOfPostData: Data, secondHalfOfPostData: Data, headers: [String: String] = [:]) -> [String: AnyObject] {
//        var dict: [String: AnyObject] = [:]
//
//        var request = URLRequest(url: URL(string: url)!)
//        request.httpMethod = "POST"
//        request.httpBody = postData
//
//        for header in headers {
//            request.addValue(header.value, forHTTPHeaderField: header.key)
//        }
//
//        // Using semaphore to make request synchronous
//        let semaphore = DispatchSemaphore(value: 0)
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
//                dict = json
//            }
//
//            semaphore.signal()
//        }
//
//        task.resume()
//        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
//
//        return dict
//    }
    
    // Implement AVAudioPlayerDelegate "did finish" callback to cleanup and notify listener of completion.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player?.delegate = nil
        self.player = nil
//        self.busy = false

        self.completionHandler!()
        self.completionHandler = nil
    }
    
}

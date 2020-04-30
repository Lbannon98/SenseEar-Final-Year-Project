//
//  TextToSpeechService.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 29/03/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import AudioToolbox

enum VoiceTypes: String {
    
    case undefined
    case ukFemale = "en-GB-Wavenet-A"
    case ukMale = "en-GB-Wavenet-B"
    case usFemale = "en-US-Wavenet-C"
    case usMale = "en-US-Wavenet-D"
    case ausFemale = "en-AU-Wavenet-C"
    case ausMale = "en-AU-Wavenet-D"
    
}

let ttsPostAPIUrl = "https://texttospeech.googleapis.com/v1/text:synthesize"
let APIKey = valueForAPIKey(named:"GOOGLE_TTS_API_KEY")

class TextToSpeechService: NSObject, AVAudioPlayerDelegate {
    
    static let shared = TextToSpeechService()
    var textBuffer = TextDivider()
    
    public static var audioPlayer = AudioPlayer()
    var completionHandler: (() -> Void)?
    
    public static var audioData: Data? = nil
    
    func makeTextToSpeechRequest(text: String, voiceType: VoiceTypes = .ukMale, completion: @escaping () -> Void) {
        
        DispatchQueue.global(qos: .background).async {
                        
            if text.count <= 5000 {
                
                let postData = self.buildSmallFilePostRequest(text: text, voiceType: voiceType)
                let headers = ["X-Goog-Api-Key": APIKey, "Content-Type": "application/json; charset=utf-8"]
                let smallResponse = self.makeSmallFilePostRequest(url: ttsPostAPIUrl, postData: postData, headers: headers)
                
                guard let audioContent = smallResponse["audioContent"] as? String else {
                        
                   print("Invalid response: \(smallResponse)")
                
                   DispatchQueue.main.async {
                       completion()
                   }
                   return
               }
                
                guard let smallAudioData = Data(base64Encoded: audioContent) else {

                   DispatchQueue.main.async {
                       completion()
                   }
                   return
                }
                    
                TextToSpeechService.audioData = smallAudioData
                self.completionHandler = completion
                
            } else if text.count > 5000 && text.count <= 10000 {
                
                let postData = self.buildMediumFilePostRequest(firstHalf: TextDivider.dividedContents[0], secondHalf: TextDivider.dividedContents[1], voiceType: voiceType)
                let headers = ["X-Goog-Api-Key": APIKey, "Content-Type": "application/json; charset=utf-8"]
                let mediumResponse = self.makeMediumFilePostRequest(url: ttsPostAPIUrl, firstHalfOfPostData: postData[1], secondHalfOfPostData: postData[0], headers: headers)
                
                guard let audioContent = mediumResponse["audioContent"] as? String else {
                                
                   print("Invalid response: \(mediumResponse)")
                
                   DispatchQueue.main.async {
                       completion()
                   }
                   return
               }
               
               guard let mediumAudioData = Data(base64Encoded: audioContent) else {
                
                   DispatchQueue.main.async {
                       completion()
                   }
                   return
               }
                
                TextToSpeechService.audioData = mediumAudioData
                self.completionHandler = completion
 
            } else if text.count > 10000 && text.count <= 20000 {
                
                let postData = self.buildLargeFilePostRequest(firstHalf: TextDivider.dividedContents[0], secondHalf: TextDivider.dividedContents[1], thirdHalf: TextDivider.dividedContents[2], fourthHalf: TextDivider.dividedContents[3], voiceType: voiceType)
                 let headers = ["X-Goog-Api-Key": APIKey, "Content-Type": "application/json; charset=utf-8"]
                let largeResponse = self.makeLargeFilePostRequest(url: ttsPostAPIUrl, firstHalfOfPostData: postData[3], secondHalfOfPostData: postData[2], thirdHalfOfPostData: postData[1], fourthHalfOfPostData: postData[0], headers: headers)
                 
                 guard let audioContent = largeResponse["audioContent"] as? String else {
                                 
                    print("Invalid response: \(largeResponse)")
                 
                    DispatchQueue.main.async {
                        completion()
                    }
                    return
                }
                
                guard let largeAudioData = Data(base64Encoded: audioContent) else {
                 
                    DispatchQueue.main.async {
                        completion()
                    }
                    return
                }
                
                TextToSpeechService.audioData = largeAudioData
                self.completionHandler = completion

            }
            
       }
        
    }
    
    private func buildSmallFilePostRequest(text: String, voiceType: VoiceTypes) -> Data {
        
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

        let data = try! JSONSerialization.data(withJSONObject: parameters)

        return data
    }
    
    private func buildMediumFilePostRequest(firstHalf: String, secondHalf: String, voiceType: VoiceTypes) -> [Data] {
        
        var data:[Data] = []
        
        var voiceConfig: [String: Any] = [
            "languageCode": "en-UK"
        ]
        
        if voiceType != .undefined {
            voiceConfig["name"] = voiceType.rawValue
        }
                
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

        let firstHalfData = try! JSONSerialization.data(withJSONObject: firstHalfParameters)
        let secondHalfData = try! JSONSerialization.data(withJSONObject: secondHalfParameters)
        
        data.append(firstHalfData)
        data.append(secondHalfData)
        
        return data
    }
    
    private func buildLargeFilePostRequest(firstHalf: String, secondHalf: String, thirdHalf: String, fourthHalf: String, voiceType: VoiceTypes) -> [Data] {
        
        var data:[Data] = []
        
        var voiceConfig: [String: Any] = [
            "languageCode": "en-UK"
        ]
        
        if voiceType != .undefined {
            voiceConfig["name"] = voiceType.rawValue
        }
                
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
        
        let thirdHalfParameters: [String: Any] = [
            "input": [
                "text": thirdHalf
            ],
            "voice": voiceConfig,
            "audioConfig": [
                "audioEncoding": "LINEAR16"
            ]
        ]
        
        let fourthHalfParameters: [String: Any] = [
            "input": [
                "text": fourthHalf
            ],
            "voice": voiceConfig,
            "audioConfig": [
                "audioEncoding": "LINEAR16"
            ]
        ]

        let firstHalfData = try! JSONSerialization.data(withJSONObject: firstHalfParameters)
        let secondHalfData = try! JSONSerialization.data(withJSONObject: secondHalfParameters)
        let thirdHalfData = try! JSONSerialization.data(withJSONObject: thirdHalfParameters)
        let fourthHalfData = try! JSONSerialization.data(withJSONObject: fourthHalfParameters)
        
        data.append(firstHalfData)
        data.append(secondHalfData)
        data.append(thirdHalfData)
        data.append(fourthHalfData)
        
        return data
    }
    
    private func makeSmallFilePostRequest(url: String, postData: Data, headers: [String: String] = [:]) -> [String: AnyObject] {
        
        var dict: [String: AnyObject] = [:]
        
        //Small Request
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = postData as Data

        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        let semaphore = DispatchSemaphore(value: 0)

        let regularTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                dict = json
            }

            semaphore.signal()
        }

        regularTask.resume()
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        return dict
    }
    
    private func makeMediumFilePostRequest(url: String, firstHalfOfPostData: Data, secondHalfOfPostData: Data, headers: [String: String] = [:]) -> [String: AnyObject] {
        
        var dict: [String: AnyObject] = [:]

        //First Half Request
        var firstHalfRequest = URLRequest(url: URL(string: url)!)
        firstHalfRequest.httpMethod = "POST"
        firstHalfRequest.httpBody = firstHalfOfPostData
        
        //Second Half Request
        var secondHalfRequest = URLRequest(url: URL(string: url)!)
        secondHalfRequest.httpMethod = "POST"
        secondHalfRequest.httpBody = secondHalfOfPostData

        for header in headers {
            firstHalfRequest.addValue(header.value, forHTTPHeaderField: header.key)
            secondHalfRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
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

        firstHalfTask.resume()
        secondHalfTask.resume()
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        return dict
    }
    
    private func makeLargeFilePostRequest(url: String, firstHalfOfPostData: Data, secondHalfOfPostData: Data, thirdHalfOfPostData: Data, fourthHalfOfPostData: Data, headers: [String: String] = [:]) -> [String: AnyObject] {
        
        var dict: [String: AnyObject] = [:]

        //First Half Request
        var firstHalfRequest = URLRequest(url: URL(string: url)!)
        firstHalfRequest.httpMethod = "POST"
        firstHalfRequest.httpBody = firstHalfOfPostData
        
        //Second Half Request
        var secondHalfRequest = URLRequest(url: URL(string: url)!)
        secondHalfRequest.httpMethod = "POST"
        secondHalfRequest.httpBody = secondHalfOfPostData

        //Third Half Request
        var thirdHalfRequest = URLRequest(url: URL(string: url)!)
        thirdHalfRequest.httpMethod = "POST"
        thirdHalfRequest.httpBody = thirdHalfOfPostData
        
        //Fourth Half Request
        var fourthHalfRequest = URLRequest(url: URL(string: url)!)
        fourthHalfRequest.httpMethod = "POST"
        fourthHalfRequest.httpBody = fourthHalfOfPostData
        
        for header in headers {
            firstHalfRequest.addValue(header.value, forHTTPHeaderField: header.key)
            secondHalfRequest.addValue(header.value, forHTTPHeaderField: header.key)
            thirdHalfRequest.addValue(header.value, forHTTPHeaderField: header.key)
            fourthHalfRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
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
        
        let thirdHalfTask = URLSession.shared.dataTask(with: thirdHalfRequest) { data, response, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                dict = json
            }

            semaphore.signal()
        }
        
        let fourthHalfTask = URLSession.shared.dataTask(with: fourthHalfRequest) { data, response, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                dict = json
            }

            semaphore.signal()
        }

        firstHalfTask.resume()
        secondHalfTask.resume()
        thirdHalfTask.resume()
        fourthHalfTask.resume()
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        return dict
    }
    
}


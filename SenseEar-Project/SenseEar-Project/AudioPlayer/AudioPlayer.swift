//
//  AudioPlayer.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 18/04/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import MediaPlayer

class AudioPlayer {

    var player: AVAudioPlayer?
    public static var isPaused = false
    public static var remainingTime: Int?
    
    var currentTime = Int()
//    var currentTimeMins: Int?
//    var currentTimeSecs: Int?
    
    public var timer: Timer?
    
    var vc: ViewController?
    
    var extractedAudio: Data?
    let audioSession = AVAudioSession()
    
    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    init() {
        
        do {
            
            guard let vc = vc else { return }
            
            vc.setupRemoteTransportControls()
            
        } catch {
            
            print("ERROR\(error)")
            
        }

    }
    
    func getAudioData() {
        
        try! self.audioSession.setCategory(.playback, mode: .default)
        try! self.audioSession.setMode(AVAudioSession.Mode.measurement)
        try! self.audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        guard let audio = TextToSpeechService.audioData else { fatalError("Couldn't get audio data") }
        extractedAudio = audio
        
        player = try! AVAudioPlayer(data: extractedAudio!)

    }
    
    func resetAudioData() {
        
        extractedAudio = nil
        
    }
    
    func playAudioContent(completion: ((_ isFinish: Bool, _ player: AVAudioPlayer, _ currentTimeInSec: Int, _ restTimeInSec: Int) -> ())? = nil) {

        try! self.audioSession.setCategory(.playback, mode: .default)
        try! self.audioSession.setMode(AVAudioSession.Mode.measurement)
        try! self.audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        guard let audio = TextToSpeechService.audioData else { return }
        extractedAudio = audio

        self.player = try! AVAudioPlayer(data: extractedAudio!)

        self.player?.play()

        vc?.setupNotificationView()

        if timer == nil {

            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.currentTime = Int(self.player!.currentTime)
                AudioPlayer.remainingTime = Int(self.player!.duration) - Int(self.currentTime)
                
                print("Current Time: \(self.currentTime)")
                print("Remaining Time: \(AudioPlayer.remainingTime)")

                if AudioPlayer.remainingTime == 0 {
                    completion?(true, self.player!, self.currentTime, AudioPlayer.remainingTime!)
                    if self.timer != nil {
                        self.timer!.invalidate()
                        self.timer = nil
                    }
                } else {
                    completion?(false, self.player!, self.currentTime, AudioPlayer.remainingTime!)
                }
            }

        }

    }

    func pauseAudioContent() {

        if player!.isPlaying {
            
            player?.pause()
            AudioPlayer.isPaused = true
            
        } else {
           AudioPlayer.isPaused = false
        }
        
        vc?.setupNotificationView()
        
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }

    }
    
    public func stopAudioContent() {
        
        player?.stop()
        
        vc?.setupNotificationView()

        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        
    }

}

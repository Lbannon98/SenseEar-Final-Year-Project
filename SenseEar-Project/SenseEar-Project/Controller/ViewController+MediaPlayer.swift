//
//  ViewController+MediaPlayer.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 09/04/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import Foundation
import MediaPlayer

extension ViewController {
    
    public func playAudio() {
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
                   
           try audioSession.setCategory(.playback, mode: .default)
           try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
           
            self.player = try! AVAudioPlayer(data: TextToSpeechService.audioData!)
           self.player?.delegate = self
           
           self.player?.prepareToPlay()
            
            DispatchQueue.main.async {
                self.player!.play()
            }
           
       } catch {
           print("Could not play audio")
       }

    }
    
//    public func playAudioFromData() {
//
//        guard let audio = TextToSpeechService.audioData else { return }
//
//        let audioSession = AVAudioSession.sharedInstance()
//
//        do {
//
//            try audioSession.setCategory(.playback, mode: .default)
//            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//
//            self.player = try! AVAudioPlayer(data: audio)
//            self.player?.delegate = self
//
//            self.player?.prepareToPlay()
//
//        } catch {
//            print("Could not play audio")
//        }
//
//    }
    
    public func pauseAudio() {
        
        self.player?.pause()
        
    }
    
    func setupMediaPlayerNotificationView() {
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        //Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            
            self.player!.play()
            return .success
        
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            
            self.player!.pause()
            return .success
        
        }
        
    }
    
    func setupNotificationView() {
        
        nowPlayingInfo = [String : Any]()
        
        nowPlayingInfo![MPMediaItemPropertyTitle] = filename
        
        nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = 1
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        
    }
    
    // Implement AVAudioPlayerDelegate "did finish" callback to cleanup and notify listener of completion.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        playAudioBtn.isHidden = false
        pauseAudioBtn.isHidden = true
        
        self.player?.delegate = nil
        self.player = nil
        self.completionHandler!()
        self.completionHandler = nil
    }
    
}

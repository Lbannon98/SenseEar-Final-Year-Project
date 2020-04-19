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
    
//    public func setupMediaPlayerNotificationView() {
//
//        let commandCenter = MPRemoteCommandCenter.shared()
//
//        //Add handler for Play Command
//        commandCenter.playCommand.addTarget { [unowned self] event in
//
////            self.player!.play()
//            return .success
//
//        }
//
//        // Add handler for Pause Command
//        commandCenter.pauseCommand.addTarget { [unowned self] event in
//
////            self.player!.pause()
//            return .success
//
//        }
//
//    }
    
    public func setupRemoteTransportControls() {
        
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.previousTrackCommand.isEnabled = false
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.skipBackwardCommand.isEnabled = false
        commandCenter.skipForwardCommand.isEnabled = false

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            
            //Update your button here for the play command
//            TextToSpeechService.audioPlayer.playAudioContent()
//            self.playAudio()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatedControlCenterAudio"), object: nil)
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            
            //Update your button here for the pause command
//            TextToSpeechService.audioPlayer.pauseAudioContent()
//            self.pauseAudio()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatedControlCenterAudio"), object: nil)
            return .success
        }
    }
    
    public func setupNotificationView() {
        
        nowPlayingInfo = [String : Any]()
        
        nowPlayingInfo![MPMediaItemPropertyTitle] = filename
        
        nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = TextToSpeechService.audioPlayer.player?.currentTime
        
        nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = TextToSpeechService.audioPlayer.player?.rate
//        nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = 1
        
        nowPlayingInfo![MPMediaItemPropertyPlaybackDuration] = TextToSpeechService.audioPlayer.player?.duration
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        let playConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
            playPauseAudioBtn.setImage(UIImage(systemName: "play", withConfiguration: playConfiguration), for: .normal)

        TextToSpeechService.audioPlayer.player?.delegate = nil
        TextToSpeechService.audioPlayer.player = nil
        
    }
    
}

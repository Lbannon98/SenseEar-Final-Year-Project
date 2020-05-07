//
//  ViewController+MediaPlayer.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 21/04/2020.
//  Copyright © 2020 Lauren Bannon. All rights reserved.
//

import Foundation
import MediaPlayer

extension ViewController {
    
    /// Controls the linking of the audio to the control centre
    public func setupRemoteTransportControls() {
            
        let commandCenter = MPRemoteCommandCenter.shared()
        
        guard let player = TextToSpeechService.audioPlayer.player else { return }
        
        //Pause Command
        commandCenter.playCommand.addTarget { [unowned self] event in

            if player.isPlaying == false {
                
                player.play()
                
                let pauseConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
                self.playPauseAudioBtn.setImage(UIImage(systemName: "pause", withConfiguration: pauseConfiguration), for: .normal)
                
                return .success
            }
            return .commandFailed
        }
        
        //Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if player.isPlaying == true {
        
                player.pause()
                
                let playConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
                self.playPauseAudioBtn.setImage(UIImage(systemName: "play", withConfiguration: playConfiguration), for: .normal)
                
                return .success
            }
            return .commandFailed
        }

    }
    
    /// Controls the setting up of the view in the control centre
    public func setupNotificationView() {
               
        guard let player = TextToSpeechService.audioPlayer.player else { return }
           
        nowPlayingInfo = [String : Any]()
       
        nowPlayingInfo![MPMediaItemPropertyTitle] = ViewController.filename

        if let image = ViewController.fileTypeLogo?.image {
           nowPlayingInfo![MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
               return image
           }
        }
       
        nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        nowPlayingInfo![MPMediaItemPropertyPlaybackDuration] = player.duration
        nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = player.rate
       
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
           
    }    
    
    /// Controls the update of the view when audio state is changed
    /// - Parameter isPause: Boolean value controlling if the audio is paused
   func updateNowPlaying(isPause: Bool) {
       
        guard let player = TextToSpeechService.audioPlayer.player else { return }
       
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else { fatalError("Couldn't get info") }

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPause ? 0 : 1

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

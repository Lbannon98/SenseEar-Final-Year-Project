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
    
}

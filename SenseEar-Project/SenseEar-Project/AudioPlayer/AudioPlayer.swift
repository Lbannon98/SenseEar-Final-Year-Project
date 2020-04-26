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

    var player: AVAudioPlayer? = nil
    
    public static var extractedAudio: Data?
    
    public var musicManager: MPMusicPlayerController?
    public var nowPlayingInfo: [String : Any]?

    func getAudioData() {
        
        guard let audio = TextToSpeechService.audioData else { fatalError("Couldn't get audio data") }
        AudioPlayer.extractedAudio = audio
                
        player = try! AVAudioPlayer(data: audio)

    }
    
    func resetAudioData() {
        
        TextToSpeechService.audioData = Data()
        
        do {
            
            player?.stop()
            player = nil
            
        } catch {
            print("ERROR: \(error)")
        }
        
    }

}

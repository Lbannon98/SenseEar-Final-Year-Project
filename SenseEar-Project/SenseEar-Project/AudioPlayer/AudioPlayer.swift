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

/// Audio Player which controls the audio data
class AudioPlayer {

    var player: AVAudioPlayer? = nil
    
    public static var extractedAudio: Data?

    /// Gets audio data from the TextToSpeechService and passes it into the player
    func getAudioData() {
        
        guard let audio = TextToSpeechService.audioData else { fatalError("Couldn't get audio data") }
        AudioPlayer.extractedAudio = audio
                
        player = try! AVAudioPlayer(data: audio)

    }
    
    /// Resets audio data in the player to be nil
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

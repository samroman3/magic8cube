//
//  SoundManager.swift
//  8cube
//
//  Created by Sam Roman on 5/23/24.
//

import SwiftUI
import AVFoundation
import CoreHaptics

class SoundManager {
    static let shared = SoundManager() 
    
    private var players: [AVAudioPlayer] = []
    private var engine: CHHapticEngine?
    private var isPlaying = false
    
    private init() {
        initializeHapticEngine()
    }
    
    private func initializeHapticEngine() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Error starting haptic engine: \(error.localizedDescription)")
        }
    }
    
    func playSound(wavFileName: String, ahapFileName: String? = nil) {
        do {
            guard let wavPath = Bundle.main.path(forResource: wavFileName, ofType:"wav") else {
                print("Invalid path")
                return
            }
            
            let wavURL = URL(fileURLWithPath: wavPath)
            
            let player = try AVAudioPlayer(contentsOf: wavURL)
            players.append(player)
            
            player.play()
            
            if let ahapFileName = ahapFileName {
                try playHapticPattern(ahapFileName)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func playSoundWithMultipleHaptics(wavFileName: String, ahapFileNames: [String]) {
          stopAllSounds()
          
          do {
              guard let wavPath = Bundle.main.path(forResource: wavFileName, ofType: "wav") else {
                  print("Invalid path")
                  return
              }
              
              let wavURL = URL(fileURLWithPath: wavPath)
              let player = try AVAudioPlayer(contentsOf: wavURL)
              players.append(player)
              
              for ahapFileName in ahapFileNames {
                  try playHapticPattern(ahapFileName)
              }
              
              player.play()
          } catch {
              print("Error: \(error.localizedDescription)")
          }
      }
    
    private func playHapticPattern(_ ahapFileName: String) throws {
        guard let engine = engine else { return }
        
        guard let ahapURL = Bundle.main.url(forResource: ahapFileName, withExtension: "ahap") else {
            print("Invalid haptic pattern path")
            return
        }
        
        let ahapPattern = try CHHapticPattern(contentsOf: ahapURL)
        let player = try engine.makeAdvancedPlayer(with: ahapPattern)
        try player.start(atTime: CHHapticTimeImmediate)
    }
    
    func playLayeredSounds(with soundData: [(wavFileName: String, ahapFileName: String?)]) {
        for sound in soundData {
            playSound(wavFileName: sound.wavFileName, ahapFileName: sound.ahapFileName)
        }
    }
    
    func playSoundsSequentially(with soundData: [(wavFileName: String, ahapFileName: String?, interval: TimeInterval)]) {
            var delay: TimeInterval = 0
            
            for sound in soundData {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.playSound(wavFileName: sound.wavFileName, ahapFileName: sound.ahapFileName)
                }
                delay += sound.interval
            }
        }
    
    func stopAllSounds() {
        for player in players {
            player.stop()
        }
        players.removeAll()
    }
}

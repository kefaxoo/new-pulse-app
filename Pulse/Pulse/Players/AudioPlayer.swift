//
//  AudioPlayer.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import AVFoundation

final class AudioPlayer {
    static let shared = AudioPlayer()
    
    fileprivate init() {}
    
    private let player: AVPlayer = {
        let player = AVPlayer()
        player.volume = 1
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        return player
    }()
    
    private var track: TrackModel?
    
    func play(from track: TrackModel) {
        self.track = track
        
        self.player.replaceCurrentItem(with: self.configurePlayerItem())
        self.player.play()
    }
    
    private func configurePlayerItem() -> AVPlayerItem? {
        guard let url = URL(string: track?.playableLinks.streaming ?? "") else { return nil }
        
        let playerItem = AVPlayerItem(url: url)
        return playerItem
    }
}

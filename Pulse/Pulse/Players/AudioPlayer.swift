//
//  AudioPlayer.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import AVFoundation
import UIKit

protocol AudioPlayerNowPlayingViewDelegate: AnyObject {
    func setupTrackInfo(_ track: TrackModel)
    func setupCover(_ cover: UIImage?)
    func updateDuration(_ duration: Float)
    func changeState(isPlaying: Bool)
}

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
    private var playlist = [TrackModel]()
    private var position = 0
    private var cover: UIImage?
    private var observer: Any?
    private var didTrackSet = false
    
    weak var nowPlayingViewDelegate: AudioPlayerNowPlayingViewDelegate?
    
    func play(from track: TrackModel, playlist: [TrackModel], position: Int) {
        self.cleanPlayer()
        
        self.track = track
        self.playlist = playlist
        self.position = position
        
        self.didTrackSet = false
        self.setupPlayerItem { [weak self] playerItem in
            self?.player.replaceCurrentItem(with: playerItem)
            self?.player.play()
        }
        
        self.setupCover()
        self.setupObserver()
        self.updatePlayableLink(at: self.nextPosition)
    }
}

// MARK: -
// MARK: Setup player methods
fileprivate extension AudioPlayer {
    func cleanPlayer() {
        self.player.replaceCurrentItem(with: nil)
        self.cover = nil
    }
    
    func setupPlayerItem(completion: @escaping((AVPlayerItem?) -> ())) {
        if let streamingLinkNeedsToRefresh = self.track?.playableLinks.streamingLinkNeedsToRefresh,
           streamingLinkNeedsToRefresh {
            self.updatePlayableLink(at: self.position) { [weak self] in
                completion(self?.createPlayerItem())
            }
        } else {
            completion(self.createPlayerItem())
        }
    }
    
    func createPlayerItem() -> AVPlayerItem? {
        guard let url = URL(string: self.track?.playableLinks.streaming ?? "") else { return nil }
        
        let playerItem = AVPlayerItem(url: url)
        return playerItem
    }
    
    func setupObserver() {
        self.observer = self.player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 600), queue: .main, using: { [weak self] _ in
            guard let self,
                  self.player.currentItem?.status == .readyToPlay
            else { return }
            
            if !self.didTrackSet,
               let track {
                self.didTrackSet = true
                self.nowPlayingViewDelegate?.setupTrackInfo(track)
                self.nowPlayingViewDelegate?.changeState(isPlaying: self.player.rate != 0)
                
                if self.cover != nil {
                    self.nowPlayingViewDelegate?.setupCover(self.cover)
                }
            }
            
            self.nowPlayingViewDelegate?.updateDuration(self.nowPlayingViewDuration)
            
            if let duration = self.player.currentItem?.duration.seconds,
               round(duration) == round(self.player.currentTime().seconds) {
                self.nowPlayingViewDelegate?.changeState(isPlaying: false)
                self.nextTrack()
            }
        })
    }
    
    func setupCover() {
        ImageManager.shared.image(from: self.track?.image.original ?? "") { [weak self] image in
            self?.cover = image
            guard let didTrackSet = self?.didTrackSet,
                  didTrackSet
            else { return }
            
            self?.nowPlayingViewDelegate?.setupCover(image)
        }
    }
    
    func updatePlayableLink(at position: Int, _ completion: (() -> ())? = nil) {
        if self.playlist[position].playableLinks.streamingLinkNeedsToRefresh {
            AudioManager.shared.updatePlayableLink(for: self.playlist[position]) { [weak self] updatedTrack in
                self?.playlist[position] = updatedTrack.track
                completion?()
            }
        }
    }
}

// MARK: -
// MARK: Computed variables
extension AudioPlayer {
    private var nowPlayingViewDuration: Float {
        guard let duration = self.player.currentItem?.duration.seconds else { return 0 }
        
        return Float(self.player.currentTime().seconds / duration)
    }
    
    var nextPosition: Int {
        return self.position + 1 < self.playlist.count ? self.position + 1 : 0
    }
}

// MARK: -
// MARK: Control player methods
extension AudioPlayer {
    func playPause() {
        if self.player.rate == 0 {
            self.player.play()
        } else {
            self.player.pause()
        }
        
        self.nowPlayingViewDelegate?.changeState(isPlaying: self.player.rate != 0)
    }
    
    func nextTrack() {
        self.play(from: self.playlist[self.nextPosition], playlist: self.playlist, position: self.nextPosition)
    }
}

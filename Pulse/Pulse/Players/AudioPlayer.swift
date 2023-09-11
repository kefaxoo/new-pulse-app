//
//  AudioPlayer.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import AVFoundation
import UIKit
import MediaPlayer

protocol AudioPlayerNowPlayingViewDelegate: AnyObject {
    func setupTrackInfo(_ track: TrackModel)
    func setupCover(_ cover: UIImage?)
    func updateDuration(_ duration: Float)
    func changeState(isPlaying: Bool)
}

final class AudioPlayer: NSObject {
    static let shared = AudioPlayer()
    
    fileprivate override init() {
        super.init()
        self.setupRemoteControl()
    }
    
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
    
    private var track          : TrackModel?
    private var playlist       = [TrackModel]()
    private var position       = 0
    private var cover          : UIImage?
    private var observer       : Any?
    private var nowPlayingInfo = [String: Any]()
    
    private let commandCenter = MPRemoteCommandCenter.shared()
    
    weak var nowPlayingViewDelegate: AudioPlayerNowPlayingViewDelegate?
    
    func play(from track: TrackModel, position: Int) {
        self.play(from: track, playlist: self.playlist, position: position)
    }
    
    func play(from track: TrackModel, playlist: [TrackModel], position: Int) {
        self.cleanPlayer()
        
        self.track = track
        self.playlist = playlist
        self.position = position
        
        self.setupPlayerItem { [weak self] playerItem in
            guard let playerItem else {
                self?.nextTrack()
                return
            }
            
            self?.player.replaceCurrentItem(with: playerItem)
            self?.player.play()
        }
        
        self.nowPlayingViewDelegate?.setupTrackInfo(track)
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
        self.nowPlayingViewDelegate?.changeState(isPlaying: false)
    }
    
    func setupPlayerItem(completion: @escaping((AVPlayerItem?) -> ())) {
        if self.track?.playableLinks?.streamingLinkNeedsToRefresh ?? true {
            self.updatePlayableLink(at: self.position) { [weak self] in
                completion(self?.createPlayerItem())
            }
        } else {
            completion(self.createPlayerItem())
        }
    }
    
    func createPlayerItem() -> AVPlayerItem? {
        guard let url = URL(string: self.track?.playableLinks?.streaming ?? "") else { return nil }
        
        let playerItem = AVPlayerItem(url: url)
        return playerItem
    }
    
    func setupObserver() {
        self.observer = self.player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 600), queue: .main, using: { [weak self] _ in
            guard let self,
                  self.player.currentItem?.status == .readyToPlay
            else { return }
            
            if track != nil {
                self.nowPlayingViewDelegate?.changeState(isPlaying: self.player.rate != 0)
            }
            
            self.nowPlayingViewDelegate?.updateDuration(self.nowPlayingViewDuration)
            self.setupNowPlaying()
            
            if let duration = self.player.currentItem?.duration.seconds,
               round(duration) == round(self.player.currentTime().seconds) {
                self.nowPlayingViewDelegate?.changeState(isPlaying: false)
                self.nextTrack()
            }
        })
    }
    
    func setupCover() {
        ImageManager.shared.image(from: self.track?.image?.original) { [weak self] image in
            self?.cover = image
            self?.nowPlayingViewDelegate?.setupCover(image)
        }
    }
    
    func updatePlayableLink(at position: Int, _ completion: (() -> ())? = nil) {
        if self.playlist[position].playableLinks?.streamingLinkNeedsToRefresh ?? true {
            AudioManager.shared.updatePlayableLink(for: self.playlist[position]) { [weak self] updatedTrack in
                self?.playlist[position] = updatedTrack.track
                completion?()
            }
        }
    }
    
    func setupRemoteControl() {
        commandCenter.playCommand.addTarget(self, action: #selector(playPause))
        commandCenter.pauseCommand.addTarget(self, action: #selector(playPause))
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(nextTrack))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(previousTrack))
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] commandEvent in
            let playerRate = self?.player.rate ?? 0
            if let event = commandEvent as? MPChangePlaybackPositionCommandEvent {
                self?.player.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: 600), completionHandler: { [weak self] success in
                    if success {
                        self?.player.rate = playerRate
                    }
                })
            }
            
            return .success
        }
    }
    
    func setupNowPlaying() {
        guard let track,
              let currentItem = player.currentItem
        else { return }
        
        nowPlayingInfo[MPMediaItemPropertyTitle]                    = track.title
        nowPlayingInfo[MPMediaItemPropertyArtist]                   = track.artistText
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle]               = track.service.title
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration]         = currentItem.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate]        = self.player.rate
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentItem.currentTime().seconds
        
        if let cover {
            nowPlayingInfo[MPMediaItemPropertyAlbumArtist] = MPMediaItemArtwork(boundsSize: cover.size, requestHandler: { size -> UIImage in
                return cover
            })
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
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
    
    var previousPosition: Int {
        return self.position - 1 > -1 ? self.position - 1 : self.playlist.count - 1
    }
}

// MARK: -
// MARK: Control player methods
extension AudioPlayer {
    @objc func playPause() -> MPRemoteCommandHandlerStatus {
        if self.player.rate == 0 {
            self.player.play()
        } else {
            self.player.pause()
        }
        
        self.nowPlayingViewDelegate?.changeState(isPlaying: self.player.rate != 0)
        return .success
    }
    
    @objc func nextTrack() -> MPRemoteCommandHandlerStatus {
        self.play(from: self.playlist[self.nextPosition], position: self.nextPosition)
        return .success
    }
    
    @objc func previousTrack() -> MPRemoteCommandHandlerStatus {
        self.play(from: self.playlist[self.previousPosition], position: self.previousPosition)
        return .success
    }
}

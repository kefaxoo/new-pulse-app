//
//  AudioPlayer.swift
//
//
//  Created by Bahdan Piatrouski on 3.03.24.
//

import AVFoundation
import AVKit
import MediaPlayer
import UIKit

open class AudioPlayer: NSObject {
    // MARK: - Typealiases
    public typealias VolumeCompletion = ((_ volume: Float) -> ())
    public typealias LikeNowPlayingCompletion = ((_ isLiked: Bool) -> ())
    public typealias PlayerStateCompletion = ((_ isPlaying: Bool) -> ())
    public typealias TrackChangeCompletion = (() -> ())
    
    private var commandCenter: MPRemoteCommandCenter {
        return MPRemoteCommandCenter.shared()
    }
    
    private var nowPlayingInfo = [String: Any]()
    
    private var durationWhenPaused: Double?
    private var currentTimeWhenPaused: Double?
    
    // MARK: - Observers
    private var outputVolumeObserver: NSKeyValueObservation?
    private var periodicTimeObserver: Any?
    
    // MARK: Targets
    private var likeTarget: Any?
    
    // MARK: - Public variables
    public lazy var player: AVPlayer = {
        let player = AVPlayer()
        player.volume = 1
        player.automaticallyWaitsToMinimizeStalling = false
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        return player
    }()
    
    public var duration: Double? {
        return self.player.rate == 0 ? self.durationWhenPaused : self.player.currentItem?.duration.seconds
    }
    
    public var currentTime: Double? {
        return self.player.rate == 0 ? self.currentTimeWhenPaused : self.player.currentTime().seconds
    }
    
    public var isPlaying: Bool {
        return self.player.currentItem?.status == .readyToPlay ? self.player.rate != 0 : false
    }
    
    public var isTrackLoaded: Bool {
        return self.player.currentItem?.status == .readyToPlay
    }
    
    public var isVolumeChanging = false
    public var isDurationChanging = false

    // MARK: - Public closures
    public var volumeDidChangeCompletion: VolumeCompletion?
    public var likeDidChangeCompletion: LikeNowPlayingCompletion?
    public var playerStateDidChangeCompletion: PlayerStateCompletion?
    public var nextTrackDidTapCompletion: TrackChangeCompletion?
    public var previousTrackDidTapCompletion: TrackChangeCompletion?
    
    public override init() {
        super.init()
        self.setupObservers()
        self.setupNotifications()
        self.setupNowPlayingCommands()
    }
    
    deinit {
        self.removeObservers()
        self.removeNotifications()
    }
}

// MARK: -
// MARK: Observers
extension AudioPlayer {
    private func setupObservers() {
        self.observeSystemVolume()
        self.setupPeriodicTimeObserver()
    }
    
    private func removeObservers() {
        self.removeObserverSystemVolume()
        self.removePeriodicTimeObserver()
    }
    
    public func setupPeriodicTimeObserver() {
        self.periodicTimeObserver = self.player.addPeriodicTimeObserver(
            forInterval: CMTime(value: 1, timescale: 600),
            queue: .main,
            using: { [weak self] _ in
                guard let self,
                      self.player.currentItem?.status == .readyToPlay
                else { return }
            
                self.changePlaybackInfoInNowPlaying()
            }
        )
    }
    
    public func removePeriodicTimeObserver() {
        guard let periodicTimeObserver else { return }
        
        self.player.removeTimeObserver(periodicTimeObserver)
    }
}

// MARK: -
// MARK: Volume
extension AudioPlayer {
    public var currentVolume: Float {
        get {
            return AVAudioSession.sharedInstance().outputVolume
        }
        set {
            guard !self.isVolumeChanging else { return }
            
            self.isVolumeChanging = true
            MPVolumeView.setVolume(newValue)
            self.isVolumeChanging = false
        }
    }
    
    private func observeSystemVolume() {
        self.outputVolumeObserver = AVAudioSession.sharedInstance().observe(
            \.outputVolume,
             options: [.new],
             changeHandler: { [weak self] audioSession, _ in
                 guard !(self?.isVolumeChanging ?? false) else { return }
            
                 self?.changeVolume(newVolume: audioSession.outputVolume)
             }
        )
    }
    
    private func removeObserverSystemVolume() {
        self.outputVolumeObserver?.invalidate()
    }
    
    private func changeVolume(newVolume: Float) {
        self.isVolumeChanging = true
        self.volumeDidChangeCompletion?(newVolume)
        self.isVolumeChanging = false
    }
}

// MARK: -
// MARK: Now playing
extension AudioPlayer {
    public func setupNowPlaying(title: String?, artist: String?, album: String?, cover: UIImage?) {
        self.nowPlayingInfo.removeAll()
        
        guard let currentItem = self.player.currentItem else { return }
        
        if let title {
            self.nowPlayingInfo[MPMediaItemPropertyTitle] = title
        }
        
        if let artist {
            self.nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        }
        
        if let album {
            self.nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
        }
        
        self.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player.rate
        self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentItem.currentTime().seconds
        
        if let cover {
            self.nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: cover.size, requestHandler: { _ -> UIImage in
                return cover
            })
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
    }
    
    func changePlaybackInfoInNowPlaying() {
        guard let currentItem = self.player.currentItem else { return }
        
        self.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player.rate
        self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentItem.currentTime().seconds
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
    }
    
    public func changeCoverInNowPlaying(_ cover: UIImage?) {
        guard let cover else { return }
        
        self.nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: cover.size, requestHandler: { _ -> UIImage in
            return cover
        })
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
    }
}

// MARK: Now Playing Commands
extension AudioPlayer {
    func setupNowPlayingCommands() {
        self.commandCenter.playCommand.addTarget(self, action: #selector(playPauseNowPlayingCommand))
        self.commandCenter.pauseCommand.addTarget(self, action: #selector(playPauseNowPlayingCommand))
        self.commandCenter.nextTrackCommand.addTarget(self, action: #selector(nextTrackNowPlayingCommand))
        self.commandCenter.previousTrackCommand.addTarget(self, action: #selector(previousTrackNowPlayingCommand))
        
        self.commandCenter.changePlaybackPositionCommand.addTarget { [weak self] commandEvent in
            guard let self,
                  let event = commandEvent as? MPChangePlaybackPositionCommandEvent
            else { return .commandFailed }
            
            let playerRate = self.player.rate
            self.player.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: 600)) { [weak self] success in
                guard success else { return }
                
                self?.player.rate = playerRate
            }
            
            return .success
        }
    }
    
    public func setupLikeNowPlayingCommand(isLiked: Bool) {
        self.commandCenter.likeCommand.removeTarget(likeTarget)
        self.commandCenter.likeCommand.isActive = isLiked
        
        self.likeTarget = self.commandCenter.likeCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            
            let newIsLiked = !self.commandCenter.likeCommand.isActive
            self.likeDidChangeCompletion?(newIsLiked)
            self.commandCenter.likeCommand.isActive.toggle()
            return .success
        }
    }
    
    @discardableResult @objc public func playPauseNowPlayingCommand() -> MPRemoteCommandHandlerStatus {
        if self.player.rate == 0 {
            self.player.play()
        } else {
            self.durationWhenPaused = self.player.currentItem?.duration.seconds
            self.currentTimeWhenPaused = self.player.currentTime().seconds
            self.player.pause()
        }
        
        self.playerStateDidChangeCompletion?(self.player.rate != 0)
        return .success
    }
    
    @discardableResult @objc public func nextTrackNowPlayingCommand() -> MPRemoteCommandHandlerStatus {
        self.nextTrackDidTapCompletion?()
        return .success
    }
    
    @discardableResult @objc func previousTrackNowPlayingCommand() -> MPRemoteCommandHandlerStatus {
        self.previousTrackDidTapCompletion?()
        return .success
    }
}

// MARK: -
// MARK: Notifications
extension AudioPlayer {
    func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidInterrupted),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }
    
    @objc func playerDidInterrupted(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeRawValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeRawValue)
        else { return }
        
        switch type {
            case .began:
                self.playPauseNowPlayingCommand()
            case .ended:
                guard let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt,
                      AVAudioSession.InterruptionOptions(rawValue: optionsValue).contains(.shouldResume)
                else { return }
                
                self.playPauseNowPlayingCommand()
            default:
                break
        }
    }
}

// MARK: -
// MARK: Prepare player
public extension AudioPlayer {
    func cleanPlayer() {
        self.player.replaceCurrentItem(with: nil)
    }
}

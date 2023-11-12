//
//  AudioPlayer.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import AVFoundation
import AVKit
import UIKit
import MediaPlayer
import AlertKit
import PulseUIComponents

protocol AudioPlayerCommonDelegate: AnyObject {
    func setupCover(_ cover: UIImage?)
    func setupTrackInfo(_ track: TrackModel)
}

protocol AudioPlayerViewDelegate: AudioPlayerCommonDelegate {
    func updateDuration(_ duration: Float)
    func changeState(isPlaying: Bool)
}

protocol AudioPlayerControllerDelegate: AudioPlayerCommonDelegate {
    func updateDuration(_ duration: Float, currentTime: Float)
}

protocol AudioPlayerTableViewDelegate: AnyObject {
    func changeStateImageView(_ state: CoverImageViewState, position: Int)
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
    
    private var playlist       = [TrackModel]()
    private var position       = 0
    private var observer       : Any?
    private var nowPlayingInfo = [String: Any]()
    
    private(set) var track: TrackModel?
    private(set) var cover: UIImage?
    
    private let commandCenter = MPRemoteCommandCenter.shared()
    
    var isDurationChanging = false
    var duration: Double? {
        return self.player.currentItem?.duration.seconds
    }
    
    weak var viewDelegate      : AudioPlayerViewDelegate?
    weak var controllerDelegate: AudioPlayerControllerDelegate?
    weak var tableViewDelegate : AudioPlayerTableViewDelegate?
    
    func play(from track: TrackModel, position: Int) {
        self.play(from: track, playlist: self.playlist, position: position, isNewPlaylist: false)
    }
    
    func play(from track: TrackModel, playlist: [TrackModel], position: Int, isNewPlaylist: Bool = true) {
        self.cleanPlayer(isNewPlaylist: isNewPlaylist)

        self.track = track
        self.playlist = playlist
        self.position = position
        
        self.setupPlayerItem { [weak self] playerItem in
            guard let playerItem,
                  let self
            else {
                _ = self?.nextTrack()
                return
            }
            
            self.player.replaceCurrentItem(with: playerItem)
            self.player.play()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.playerDidFinishPlaying),
                name: .AVPlayerItemDidPlayToEndTime,
                object: self.player.currentItem
            )
        }
        
        self.tableViewDelegate?.changeStateImageView(.loading, position: self.position)
        self.setupTrackInfoInDelegates()
        self.setupCover()
        self.setupObserver()
        self.updatePlayableLink(at: self.nextPosition)
//        if isNewPlaylist {
//            self.setupCache()
//        } else {
//            SessionCacheManager.shared.addTrackToQueue(track)
//        }
    }
    
    func state(for track: TrackModel) -> CoverImageViewState {
        guard track == self.track else { return .stopped }
        
        if self.player.currentItem?.status == .readyToPlay {
            return self.player.rate == 0 ? .paused : .playing
        } else {
            return .loading
        }
    }
    
    func cleanPlayer(isNewPlaylist: Bool = true) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
        self.player.replaceCurrentItem(with: nil)
        self.cover = nil
        self.viewDelegate?.changeState(isPlaying: false)
        self.tableViewDelegate?.changeStateImageView(.stopped, position: self.position)
        guard isNewPlaylist else { return }
        
        SessionCacheManager.shared.cleanAllCache()
    }
}

// MARK: -
// MARK: Setup player methods
fileprivate extension AudioPlayer {
    func setupPlayerItem(completion: @escaping((AudioPlayerItem?) -> ())) {
        setupPlayerItem(forTrackAt: self.position, completion: completion)
    }
    
    func setupPlayerItem(forTrackAt position: Int, completion: @escaping((AudioPlayerItem?) -> ())) {
        if self.playlist[position].needFetchingPlayableLinks {
            self.updatePlayableLink(at: position) { [weak self] in
                self?.createPlayerItem(forTrackAt: position, completion: completion)
            }
        } else {
            self.createPlayerItem(forTrackAt: position, completion: completion)
        }
    }
    
    func createPlayerItem(completion: @escaping((AudioPlayerItem?) -> ())) {
        self.createPlayerItem(forTrackAt: self.position, completion: completion)
    }
    
    func createPlayerItem(forTrackAt position: Int, completion: @escaping((AudioPlayerItem?) -> ())) {
        AudioPlayerItem.initialize(with: self.playlist[position], completion: completion)
    }
    
    func setupObserver() {
        self.observer = self.player.addPeriodicTimeObserver(
            forInterval: CMTime(value: 1, timescale: 600),
            queue: .main,
            using: { [weak self] _ in
                guard let self,
                      self.player.currentItem?.status == .readyToPlay
                else { return }
                
                if self.track != nil {
                    self.viewDelegate?.changeState(isPlaying: self.player.rate != 0)
                }
                
                self.setupDurationInDelegates()
                self.setupNowPlaying()
                
                if self.player.currentItem?.status == .readyToPlay {
                    self.tableViewDelegate?.changeStateImageView(self.player.rate == 0 ? .paused : .playing, position: self.position)
                } else {
                    self.tableViewDelegate?.changeStateImageView(.loading, position: self.position)
                }
            }
        )
    }
    
    func setupCover() {
        if let coverModel = self.track?.image,
           coverModel.isSmallEqualToOriginal,
           !coverModel.isImageLocal {
            switch self.track?.source {
                case .soundcloud:
                    PulseProvider.shared.soundcloudArtwork(exampleLink: coverModel.original) { [weak self] cover in
                        self?.track?.image = ImageModel(cover)
                        self?.fetchCover(from: cover.xl)
                        
                        guard let self else { return }
                        
                        self.playlist[self.position].image = ImageModel(cover)
                    }
                default:
                    break
            }
            
            return
        }
        
        self.fetchCover(from: self.track?.image?.original)
    }
    
    func fetchCover(from link: String?) {
        ImageManager.shared.image(from: link) { [weak self] image, _ in
            DispatchQueue.main.async { [weak self] in
                self?.cover = image
                self?.setupCoverInDelegates()
                self?.setupNowPlaying()
            }
        }
    }
    
    func updatePlayableLink(at position: Int, _ completion: (() -> ())? = nil) {
        if self.playlist[position].needFetchingPlayableLinks {
            AudioManager.shared.getPlayableLink(for: self.playlist[position]) { [weak self] updatedTrack in
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
                self?.player.seek(
                    to: CMTime(seconds: event.positionTime, preferredTimescale: 600),
                    completionHandler: { [weak self] success in
                        guard success else { return }
                        
                        self?.player.rate = playerRate
                    }
                )
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
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
                boundsSize: cover.size,
                requestHandler: { _ -> UIImage in
                    return cover
                }
            )
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruptions),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }
    
    func setupCache() {
        let freeCountOfCache = SessionCacheManager.shared.freeCountOfCache
        if self.playlist.count < freeCountOfCache {
            self.playlist.forEach { [weak self] track in
                guard track != self?.track else { return }
                
                SessionCacheManager.shared.addTrackToQueue(track)
            }
        } else {
            if self.nextPosition == 0 {
                for i in 0..<freeCountOfCache {
                    SessionCacheManager.shared.addTrackToQueue(self.playlist[i])
                }
            } else {
                for i in self.nextPosition..<self.playlist.count {
                    SessionCacheManager.shared.addTrackToQueue(self.playlist[i])
                }
            }
        }
    }
}

// MARK: -
// MARK: Computed variables
extension AudioPlayer {
    private var viewDuration: Float {
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
        
        self.viewDelegate?.changeState(isPlaying: self.player.rate != 0)
        if self.player.currentItem?.status == .readyToPlay {
            self.tableViewDelegate?.changeStateImageView(self.player.rate == 0 ? .stopped : .playing, position: self.position)
        }
        
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
    
    func updateTimePosition(_ position: Float) {
        guard let duration = self.player.currentItem?.duration.seconds else { return }
        
        self.player.seek(to: CMTime(seconds: duration * Double(position), preferredTimescale: 600))
    }
}

// MARK: -
// MARK: Edit playlist
extension AudioPlayer {
    func playNext(_ track: TrackModel) {
        self.playlist.insert(track, at: self.nextPosition)
        let type: AlertIcon
        if let image = Constants.Images.playNext.image {
            type = .custom(image)
        } else {
            type = .done
        }
        
        AlertView.shared.present(title: "Playing next", alertType: type, system: .iOS17AppleMusic)
    }
    
    func playLast(_ track: TrackModel) {
        self.playlist.append(track)
        let type: AlertIcon
        if let image = Constants.Images.playLast.image {
            type = .custom(image)
        } else {
            type = .done
        }
        
        AlertView.shared.present(title: "Playing last", alertType: type, system: .iOS17AppleMusic)
    }
}

// MARK: -
// MARK: Delegates methods
extension AudioPlayer {
    private func setupCoverInDelegates() {
        self.viewDelegate?.setupCover(self.cover)
        self.controllerDelegate?.setupCover(self.cover)
    }
    
    private func setupTrackInfoInDelegates() {
        guard let track else { return }
        
        self.viewDelegate?.setupTrackInfo(track)
        self.controllerDelegate?.setupTrackInfo(track)
    }
    
    private func setupDurationInDelegates() {
        self.viewDelegate?.updateDuration(self.viewDuration)
        guard !self.isDurationChanging,
              let duration = self.player.currentItem?.duration.seconds else { return }
        
        self.controllerDelegate?.updateDuration(Float(duration), currentTime: Float(self.player.currentTime().seconds))
    }
}

// MARK: -
// MARK: Observable methods
fileprivate extension AudioPlayer {
    @objc func playerDidFinishPlaying() {
        if let track,
           LibraryManager.shared.isTrackInLibrary(track) {
            PulseProvider.shared.incrementCountListen(for: track)
        }
        
        _ = self.nextTrack()
    }
    
    @objc private func handleInterruptions(_ notification: NSNotification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else { return }
        
        if type == .began {
            _ = self.playPause()
            self.viewDelegate?.changeState(isPlaying: false)
        } else if type == .ended {
            guard let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                _ = self.playPause()
                self.viewDelegate?.changeState(isPlaying: true)
            }
        }
    }
}

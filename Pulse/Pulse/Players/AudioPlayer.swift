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
import CachingPlayerItem

protocol AudioPlayerNowPlayingViewDelegate: AnyObject {
    func setupTrackInfo(_ track: TrackModel)
    func setupCover(_ cover: UIImage?)
    func updateDuration(_ duration: Float)
    func changeState(isPlaying: Bool)
}

protocol AudioPlayerNowPlayingControllerDelegate: AnyObject {
    func setupCover(_ cover: UIImage?)
    func setupTrackInfo(_ track: TrackModel)
    func updateDuration(_ duration: Float, currentTime: Float)
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
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        return player
    }()

    private var playlist       = [TrackModel]()
    private var position       = 0
    private var observer       : Any?
    private var nowPlayingInfo = [String: Any]()
    private var nextPlayerItem : CachingPlayerItem?
    
    private(set) var track: TrackModel?
    private(set) var cover: UIImage?
    
    private let commandCenter = MPRemoteCommandCenter.shared()
    
    var isDurationChanging = false
    
    weak var nowPlayingViewDelegate          : AudioPlayerNowPlayingViewDelegate?
    weak var nowPlayingViewControllerDelegate: AudioPlayerNowPlayingControllerDelegate?
    
    func play(from track: TrackModel, position: Int) {
        self.play(from: track, playlist: self.playlist, position: position, isNewPlaylist: false)
    }
    
    func play(from track: TrackModel, playlist: [TrackModel], position: Int, isNewPlaylist: Bool = true) {
        self.cleanPlayer()
        
        self.track = track
        self.playlist = playlist
        self.position = position
        
        if let nextPlayerItem, !isNewPlaylist {
            self.player.replaceCurrentItem(with: nextPlayerItem)
            self.player.play()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(playerDidFinishPlaying),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: self.player.currentItem
            )
        } else {
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
                    name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                    object: self.player.currentItem
                )
            }
        }
        
        self.setupTrackInfoInDelegates()
        self.setupCover()
        self.setupObserver()
        self.updatePlayableLink(at: self.nextPosition)
        self.setupNextPlayerItem()
    }
}

// MARK: -
// MARK: Setup player methods
fileprivate extension AudioPlayer {
    func cleanPlayer() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
        self.player.replaceCurrentItem(with: nil)
        self.cover = nil
        self.nowPlayingViewDelegate?.changeState(isPlaying: false)
    }
    
    func setupPlayerItem(completion: @escaping((CachingPlayerItem?) -> ())) {
        setupPlayerItem(forTrackAt: self.position, completion: completion)
    }
    
    func setupPlayerItem(forTrackAt position: Int, completion: @escaping((CachingPlayerItem?) -> ())) {
        if self.playlist[position].playableLinks?.streamingLinkNeedsToRefresh ?? true {
            self.updatePlayableLink(at: position) { [weak self] in
                completion(self?.createPlayerItem(forTrackAt: position))
            }
        } else {
            completion(self.createPlayerItem(forTrackAt: position))
        }
    }
    
    func createPlayerItem() -> CachingPlayerItem? {
        return createPlayerItem(forTrackAt: self.position)
    }
    
    func createPlayerItem(forTrackAt position: Int) -> CachingPlayerItem? {
        guard let url = URL(string: self.playlist[position].playableLinks?.streaming ?? "") else { return nil }
        
        let playerItem = CachingPlayerItem(url: url)
        playerItem.delegate = self
        DispatchQueue.global(qos: .background).async {
            playerItem.download()
        }
        
        return playerItem
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
                    self.nowPlayingViewDelegate?.changeState(isPlaying: self.player.rate != 0)
                }
                
                self.setupDurationInDelegates()
                self.setupNowPlaying()
            }
        )
    }
    
    func setupCover() {
        ImageManager.shared.image(from: self.track?.image?.original) { [weak self] image in
            DispatchQueue.main.async { [weak self] in
                self?.cover = image
                self?.setupCoverInDelegates()
                self?.setupNowPlaying()
            }
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
    
    func setupNextPlayerItem() {
        self.setupPlayerItem(forTrackAt: self.nextPosition) { [weak self] nextPlayerItem in
            self?.nextPlayerItem = nextPlayerItem
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
        self.nowPlayingViewDelegate?.setupCover(self.cover)
        self.nowPlayingViewControllerDelegate?.setupCover(self.cover)
    }
    
    private func setupTrackInfoInDelegates() {
        guard let track else { return }
        
        self.nowPlayingViewDelegate?.setupTrackInfo(track)
        self.nowPlayingViewControllerDelegate?.setupTrackInfo(track)
    }
    
    private func setupDurationInDelegates() {
        self.nowPlayingViewDelegate?.updateDuration(self.nowPlayingViewDuration)
        guard !self.isDurationChanging,
              let duration = self.player.currentItem?.duration.seconds else { return }
        
        self.nowPlayingViewControllerDelegate?.updateDuration(Float(duration), currentTime: Float(self.player.currentTime().seconds))
    }
}

// MARK: -
// MARK: CachingPlayerItemDelegate
extension AudioPlayer: CachingPlayerItemDelegate {
    func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        debugLog(bytesDownloaded, "/", bytesExpected)
    }
}

// MARK: -
// MARK: Observable methods
fileprivate extension AudioPlayer {
    @objc func playerDidFinishPlaying() {
        _ = self.nextTrack()
    }
}

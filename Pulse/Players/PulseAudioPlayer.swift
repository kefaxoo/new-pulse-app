//
//  PulseAudioPlayer.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 3.03.24.
//

import Foundation
import PulseMedia
import PulseUIComponents
import UIKit
import AVFoundation

final class PulseAudioPlayer: PulseMedia.AudioPlayer {
    private typealias AudioPlayerItemCompletion = ((_ playerItem: AudioPlayerItem?) -> ())
    
    static let shared = PulseAudioPlayer()
    
    override init() {
        super.init()
    }
    
    // MARK: -
    // MARK: Media
    private var playlist = [TrackModel]()
    private var currentPosition = 0
    private var currentState: CoverImageViewState = .stopped
    
    private(set) var track: TrackModel?
    private(set) var cover: UIImage?
    
    private var nextPosition: Int {
        return self.currentPosition + 1 < self.playlist.count ? self.currentPosition + 1 : 0
    }
    
    private var previousPosition: Int {
        return self.currentPosition - 1 > -1 ? self.currentPosition - 1 : self.playlist.count - 1
    }
    
    // MARK: -
    // MARK: Observers
    private var currentItemStatusObserver: NSKeyValueObservation?
}

// MARK: -
// MARK: Setup player
extension PulseAudioPlayer {
    func play(from track: TrackModel, position: Int) {
        self.play(
            from: track,
            playlist: self.playlist,
            position: position,
            isNewPlaylist: false
        )
    }
    
    func play(from track: TrackModel, playlist: [TrackModel], position: Int, isNewPlaylist: Bool = true) {
        self.cleanPlayer(isNewPlaylist: isNewPlaylist)
        
        self.track = track
        self.playlist = playlist
        self.currentPosition = position
        
        self.setupPlayerItem { [weak self] playerItem in
            guard let self,
                  let playerItem
            else {
                self?.nextTrackNowPlayingCommand()
                return
            }
            
            self.player.replaceCurrentItem(with: playerItem)
            self.player.play()
            self.setupDidFinishPlayingNotification()
            self.setupCurrentItemStatusObserver()
        }
        
        self.setupCover()
        
        self.setupLikeNowPlayingCommand()
        self.setupPeriodicTimeObserver()
        self.setupNowPlaying(
            title: track.title,
            artist: track.artistText,
            album: track.service.title,
            cover: nil
        )
        
        self.updatePlayableLinkIfNeeded(forTrackAtPosition: self.nextPosition) { [weak self] in
            guard let self else { return }
            
            SessionCacheManager.shared.addTrackToQueue(self.playlist[self.nextPosition])
        }
    }
}

// MARK: -
// MARK: Prepare player
private extension PulseAudioPlayer {
    func cleanPlayer(isNewPlaylist: Bool = true) {
        super.cleanPlayer()
        
        self.removeDidFinishPlayingNotification()
        self.removePeriodicTimeObserver()
        self.removeCurrentItemStatusObserver()
        
        self.currentState = .loading
        
        guard isNewPlaylist else { return }
        
        SessionCacheManager.shared.cleanAllCache()
    }
    
    func updatePlayableLinkIfNeeded(forTrackAtPosition position: Int, _ completion: (() -> ())? = nil) {
        guard self.playlist[position].needFetchingPlayableLinks else {
            completion?()
            return
        }
        
        AudioManager.shared.getPlayableLink(for: self.playlist[position]) { [weak self] updatedTrack in
            self?.playlist[position] = updatedTrack.track
            completion?()
        }
    }
    
    private func setupPlayerItem(completion: @escaping AudioPlayerItemCompletion) {
        self.setupPlayerItem(forTrackAtPosition: self.currentPosition, completion: completion)
    }
    
    private func setupPlayerItem(forTrackAtPosition position: Int, completion: @escaping AudioPlayerItemCompletion) {
        if self.playlist[position].needFetchingPlayableLinks {
            self.updatePlayableLinkIfNeeded(forTrackAtPosition: position) { [weak self] in
                self?.createPlayerItem(forTrackAtPosition: position, completion: completion)
            }
        } else {
            self.createPlayerItem(forTrackAtPosition: position, completion: completion)
        }
    }
    
    private func createPlayerItem(forTrackAtPosition position: Int, completion: @escaping AudioPlayerItemCompletion) {
        AudioPlayerItem.initialize(with: self.playlist[position], completion: completion)
    }
}

// MARK: -
// MARK: Cover
private extension PulseAudioPlayer {
    func setupCover() {
        guard let coverModel = self.track?.image,
              coverModel.isSmallEqualToOriginal,
              !coverModel.isImageLocal
        else {
            self.fetchCover(from: self.track?.image?.original)
            return
        }
        
        switch self.track?.source {
            case .soundcloud:
                PulseProvider.shared.soundcloudArtworkV2(link: coverModel.original) { [weak self] cover in
                    let imageModel = ImageModel(cover)
                    self?.track?.image = imageModel
                    self?.fetchCover(from: cover.xl)
                    
                    guard let self else { return }
                    
                    self.playlist[self.currentPosition].image = imageModel
                }
            case .pulse:
                self.fetchCover(from: coverModel.original)
            default:
                break
        }
    }
    
    func fetchCover(from link: String?) {
        ImageManager.shared.image(from: link) { [weak self] image, _ in
            DispatchQueue.main.async {
                self?.cover = image
                self?.changeCoverInNowPlaying(image)
            }
        }
    }
}

// MARK: -
// MARK: Now Playing
extension PulseAudioPlayer {
    func setupLikeNowPlayingCommand() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let track = self?.track else { return }
            
            let isLiked = LibraryManager.shared.isTrackInLibrary(track)
            self?.setupLikeNowPlayingCommand(isLiked: isLiked)
        }
    }
}

// MARK: -
// MARK: Notifications
private extension PulseAudioPlayer {
    func setupDidFinishPlayingNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: AVPlayerItem.didPlayToEndTimeNotification,
            object: self.player.currentItem
        )
    }
    
    func removeDidFinishPlayingNotification() {
        NotificationCenter.default.removeObserver(
            self,
            name: AVPlayerItem.didPlayToEndTimeNotification,
            object: self.player.currentItem
        )
    }
    
    @objc func playerDidFinishPlaying(_ notification: Notification) {
        if let track,
           LibraryManager.shared.isTrackInLibrary(track) {
            PulseProvider.shared.incrementCountListen(for: track)
        }
        
        self.nextTrackNowPlayingCommand()
    }
}

// MARK: -
// MARK: Observers
private extension PulseAudioPlayer {
    func setupCurrentItemStatusObserver() {
        self.currentItemStatusObserver = self.player.currentItem?.observe(\.status, options: .new, changeHandler: { [weak self] playerItem, _ in
            guard playerItem.status == .readyToPlay else { return }
        })
    }
    
    func removeCurrentItemStatusObserver() {
        self.currentItemStatusObserver?.invalidate()
    }
}

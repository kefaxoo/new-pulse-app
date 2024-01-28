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
    func resetView()
}

protocol AudioPlayerControllerDelegate: AudioPlayerCommonDelegate {
    func updateDuration(_ duration: Float, currentTime: Float)
    func updateVolume(_ volume: Float)
    func shouldFetchCanvas()
    func trackIsReadyToPlay()
    func trackDidFinishPlaying()
}

extension AudioPlayerControllerDelegate {
    func trackDidFinishPlaying() {}
}

protocol AudioPlayerTableViewDelegate: AnyObject {
    func changeStateImageView(_ state: CoverImageViewState, for track: TrackModel)
}

final class AudioPlayer: NSObject {
    static let shared = AudioPlayer()
    
    override init() {
        super.init()
        self.setupRemoteControl()
    }
    
    private lazy var player: AVPlayer = {
        let player = AVPlayer()
        player.volume = 1
        player.automaticallyWaitsToMinimizeStalling = false
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            debugLog(error)
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        return player
    }()
    
    private var playlist                 = [TrackModel]()
    private var position                 = 0
    private var observer                 : Any?
    private var nowPlayingInfo           = [String: Any]()
    private var outputVolumeObserver     : Any?
    private var currentItemStatusObserver: Any?
    private var previousTaps             = 0
    private var currentState             : CoverImageViewState = .stopped
    private var likeTarget               : Any?
    
    private(set) var track: TrackModel?
    private(set) var cover: UIImage?
    
    private var durationWhenPaused: Double?
    private var currentTimeWhenPaused: Double?
    
    private let commandCenter = MPRemoteCommandCenter.shared()
    
    var isDurationChanging = false
    var isVolumeChanging   = false
    
    var duration: Double? {
        return self.player.rate == 0 ? self.durationWhenPaused : self.player.currentItem?.duration.seconds
    }
    
    var currentTime: Double? {
        return self.player.rate == 0 ? self.currentTimeWhenPaused : self.player.currentTime().seconds
    }
    
    var isPlaying: Bool {
        return self.player.currentItem?.status == .readyToPlay ? self.player.rate != 0 : false
    }
    
    var isTrackLoaded: Bool {
        return self.player.currentItem?.status == .readyToPlay
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
                self?.nextTrack()
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
            
            self.currentItemStatusObserver = self.player.currentItem?.observe(\.status, options: .new, changeHandler: { [weak self] playerItem, _ in
                guard playerItem.status == .readyToPlay else { return }
                
                self?.controllerDelegate?.trackIsReadyToPlay()
            })
        }
        
        self.tableViewDelegate?.changeStateImageView(.loading, for: track)
        self.setupTrackInfoInDelegates()
        self.setupCover()
        self.setupObserver()
        self.updatePlayableLink(at: self.nextPosition) { [weak self] in
            guard let nextPosition = self?.nextPosition,
                  let track = self?.playlist[nextPosition]
            else { return }
            
            SessionCacheManager.shared.addTrackToQueue(track)
        }
        
        self.setupTrackNowPlayingCommands()
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
        self.currentItemStatusObserver = nil
        self.player.replaceCurrentItem(with: nil)
        self.cover = nil
        self.viewDelegate?.changeState(isPlaying: false)
        self.previousTaps = 0
        self.currentState = .loading
        if let track {
            self.tableViewDelegate?.changeStateImageView(.stopped, for: track)
        }
        
        guard isNewPlaylist else { return }
        
        SessionCacheManager.shared.cleanAllCache()
    }
    
    func cleanPlayerFromStory() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
        self.currentItemStatusObserver = nil
        self.player.replaceCurrentItem(with: nil)
        self.cover = nil
        self.track = nil
        self.playlist.removeAll()
        SessionCacheManager.shared.cleanAllCache()
        self.viewDelegate?.resetView()
        self.viewDelegate?.changeState(isPlaying: false)
        self.viewDelegate?.updateDuration(0)
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
                
                guard let track else { return }
                
                let state: CoverImageViewState
                if self.player.currentItem?.status == .readyToPlay {
                    state = self.player.rate == 0 ? .paused : .playing
                } else {
                    state = .loading
                }
                
                guard state != self.currentState else { return }
                
                self.currentState = state
                self.tableViewDelegate?.changeStateImageView(state, for: track)
            }
        )
    }
    
    func setupCover() {
        if let coverModel = self.track?.image,
           coverModel.isSmallEqualToOriginal,
           !coverModel.isImageLocal {
            switch self.track?.source {
                case .soundcloud:
                    if AppEnvironment.current.isDebug || SettingsManager.shared.localFeatures.newSoundcloud?.prod ?? false {
                        PulseProvider.shared.soundcloudArtworkV2(link: coverModel.original) { [weak self] cover in
                            self?.track?.image = ImageModel(cover)
                            self?.fetchCover(from: cover.xl)
                            
                            guard let self else { return }
                            
                            self.playlist[self.position].image = ImageModel(cover)
                        }
                    } else {
                        PulseProvider.shared.soundcloudArtwork(exampleLink: coverModel.original) { [weak self] cover in
                            self?.track?.image = ImageModel(cover)
                            self?.fetchCover(from: cover.xl)
                            
                            guard let self else { return }
                            
                            self.playlist[self.position].image = ImageModel(cover)
                        }
                    }
                case .pulse:
                    self.fetchCover(from: coverModel.original)
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
        } else {
            completion?()
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

extension AudioPlayer {
    func setupTrackNowPlayingCommands() {
        if #available(iOS 17.0, *) {
            guard let track else { return }
            
            commandCenter.likeCommand.removeTarget(likeTarget)
            
            commandCenter.likeCommand.isActive = LibraryManager.shared.isTrackInLibrary(track)
            
            self.likeTarget = commandCenter.likeCommand.addTarget { [track, weak self] _ in
                guard let self else { return .commandFailed }
                
                let state: TrackLibraryState
                if self.commandCenter.likeCommand.isActive {
                    LibraryManager.shared.dislikeTrack(track)
                    state = .none
                } else {
                    LibraryManager.shared.likeTrack(track)
                    state = .added
                }
                
                NotificationCenter.default.post(name: .updateLibraryState, object: nil, userInfo: [
                    "track": track,
                    "state": state
                ])
                
                self.commandCenter.likeCommand.isActive.toggle()
                return .success
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
    func playPauseWith(isPlaying: Bool) {
        if isPlaying {
            self.player.play()
        } else {
            self.durationWhenPaused = self.player.currentItem?.duration.seconds
            self.currentTimeWhenPaused = self.player.currentTime().seconds
            self.player.pause()
        }
        
        self.viewDelegate?.changeState(isPlaying: isPlaying)
        if self.player.currentItem?.status == .readyToPlay,
           let track {
            self.tableViewDelegate?.changeStateImageView(self.player.coverState, for: track)
        }
    }
    
    @discardableResult @objc func playPause() -> MPRemoteCommandHandlerStatus {
        if self.player.rate == 0 {
            self.player.play()
        } else {
            self.durationWhenPaused = self.player.currentItem?.duration.seconds
            self.currentTimeWhenPaused = self.player.currentTime().seconds
            self.player.pause()
        }
        
        self.viewDelegate?.changeState(isPlaying: self.player.rate != 0)
        if self.player.currentItem?.status == .readyToPlay,
           let track {
            self.tableViewDelegate?.changeStateImageView(self.player.coverState, for: track)
        }
        
        return .success
    }
    
    @discardableResult @objc func nextTrack() -> MPRemoteCommandHandlerStatus {
        self.play(from: self.playlist[self.nextPosition], position: self.nextPosition)
        return .success
    }
    
    @discardableResult @objc func previousTrack() -> MPRemoteCommandHandlerStatus {
        if self.player.currentTime().seconds > 5 {
            self.previousTaps += 1
            if self.previousTaps < 2 {
                self.player.seek(to: .zero)
                return .success
            }
        }
        
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
        
        AlertView.shared.present(title: Localization.Lines.playingNext.localization, alertType: type, system: .iOS17AppleMusic)
    }
    
    func playLast(_ track: TrackModel) {
        self.playlist.append(track)
        let type: AlertIcon
        if let image = Constants.Images.playLast.image {
            type = .custom(image)
        } else {
            type = .done
        }
        
        AlertView.shared.present(title: Localization.Lines.playingLast.localization, alertType: type, system: .iOS17AppleMusic)
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
extension AudioPlayer {
    @objc fileprivate func playerDidFinishPlaying() {
        if let track,
           LibraryManager.shared.isTrackInLibrary(track) {
            PulseProvider.shared.incrementCountListen(for: track)
        }
        
        self.controllerDelegate?.trackDidFinishPlaying()
        self.nextTrack()
    }
    
    @objc fileprivate func handleInterruptions(_ notification: NSNotification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else { return }
        
        if type == .began {
            self.playPause()
            self.viewDelegate?.changeState(isPlaying: false)
        } else if type == .ended {
            guard let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                self.playPause()
                self.viewDelegate?.changeState(isPlaying: true)
            }
        }
    }
}

// MARK: -
// MARK: Volume methods
extension AudioPlayer {
    func setVolume(_ volume: Float) {
        guard !self.isVolumeChanging else { return }
        
        self.isVolumeChanging = true
        MPVolumeView.setVolume(volume)
        self.isVolumeChanging = false
    }
    
    var currentVolume: Float {
        return AVAudioSession.sharedInstance().outputVolume
    }
    
    func observeSystemVolume() {
        self.outputVolumeObserver = AVAudioSession.sharedInstance().observe(\.outputVolume, options: [.new]) { [weak self] audioSession, _ in
            guard !(self?.isVolumeChanging ?? true) else { return }
            
            self?.isVolumeChanging = true
            self?.controllerDelegate?.updateVolume(audioSession.outputVolume)
            self?.isVolumeChanging = false
        }
    }
    
    func removeSystemVolumeObserver() {
        (self.outputVolumeObserver as? NSKeyValueObservation)?.invalidate()
    }
}

//
//  VideoPlayer.swift
//
//
//  Created by Bahdan Piatrouski on 1.01.24.
//

import Foundation
import AVFoundation

extension NSNotification.Name {
    public static let resumeVideo = NSNotification.Name("resumeVideo")
}

open class VideoPlayer {
    // MARK: Private variables
    private lazy var player: AVPlayer = {
        let player = AVPlayer()
        player.isMuted = true
        return player
    }()
    
    private var areObserversCreated = false
    private var currentItemStatusObservation: Any?
    
    // MARK: Public variables
    public weak var delegate: VideoPlayerDelegate?
    
    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(resumePlayer), name: .resumeVideo, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .resumeVideo, object: nil)
    }
}

// MARK: -
// MARK: Private methods
private extension VideoPlayer {
    func setupObservers() {
        self.currentItemStatusObservation = self.player.currentItem?.observe(
            \.status,
             options: .new,
             changeHandler: { [weak self] currentItem, _ in
                guard let self,
                      currentItem.status == .readyToPlay
                else { return }
                
                self.delegate?.setupLayer(AVPlayerLayer(player: self.player))
             }
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: self.player.currentItem
        )
        
        self.areObserversCreated = true
    }
}

// MARK: -
// MARK: Public methods
public extension VideoPlayer {
    func setVideo(from link: String?) {
        self.cleanPlayer()
        guard let link,
              let url = URL(string: link)
        else { return }
        
        self.player.replaceCurrentItem(with: AVPlayerItem(url: url))
        self.setupObservers()
        self.player.play()
    }
    
    func cleanPlayer() {
        if self.areObserversCreated {
            self.currentItemStatusObservation = nil
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
            self.areObserversCreated = false
        }
        
        self.player.pause()
        self.player.replaceCurrentItem(with: nil)
    }
}

// MARK: -
// MARK: Observer methods
extension VideoPlayer {
    @objc private func playerDidFinishPlaying() {
        self.player.seek(to: .zero)
        self.player.play()
    }
}

// MARK: -
// MARK: Actions
extension VideoPlayer {
    @objc func resumePlayer(_ sender: Notification) {
        self.player.play()
    }
}

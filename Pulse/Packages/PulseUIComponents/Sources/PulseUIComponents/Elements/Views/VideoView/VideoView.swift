//
//  VideoView.swift
//
//
//  Created by Bahdan Piatrouski on 1.01.24.
//

import UIKit
import AVFoundation
import PulseMedia

open class VideoView: BaseUIView {
    private lazy var videoPlayer: VideoPlayer = {
        let player = VideoPlayer()
        player.delegate = self
        return player
    }()
    
    public var isVideoLoaded = false
    private var videoLayer: AVPlayerLayer?
    
    public weak var videoViewDelegate: VideoViewDelegate?
    
    public init() {
        super.init(frame: .zero)
        self.alpha = 0
        self.backgroundColor = .clear
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// MARK: Public methods
extension VideoView {
    public func setVideo(from link: String?) {
        self.isVideoLoaded = false
        self.videoPlayer.setVideo(from: link)
    }
    
    @objc open func removeVideo() {
        self.isVideoLoaded = false
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.alpha = 0
        } completion: { [weak self] _ in
            self?.videoLayer?.removeFromSuperlayer()
            self?.videoPlayer.cleanPlayer()
        }
    }
}

// MARK: -
// MARK: VideoPlayerDelegate
extension VideoView: VideoPlayerDelegate {
    public func setupLayer(_ layer: AVPlayerLayer?) {
        guard let layer else { return }
        
        self.layer.addSublayer(layer)
        layer.frame = self.bounds
        layer.videoGravity = .resizeAspectFill
        self.isVideoLoaded = true
        self.videoLayer = layer
        self.videoViewDelegate?.videoWasLoaded()
    }
}

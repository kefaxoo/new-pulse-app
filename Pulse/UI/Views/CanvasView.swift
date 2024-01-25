//
//  CanvasView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.12.23.
//

import UIKit
import PulseUIComponents

protocol CanvasViewDelegate: VideoViewDelegate {}

final class CanvasView: VideoView {
    enum CanvasType {
        case video
        case image
        case none
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    weak var delegate: CanvasViewDelegate?
    
    var isCanvasLoaded: Bool {
        return super.isVideoLoaded || self.imageView.image != nil
    }
    
    override init() {
        super.init()
        super.videoViewDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCanvas(from link: String, canvasType type: CanvasView.CanvasType) {
        self.imageView.image = nil
        
        switch type {
            case .video:
                super.setVideo(from: link)
            case .image:
                self.alpha = 1
                self.imageView.setImage(from: link) { [weak self] in
                    self?.delegate?.videoWasLoaded()
                }
            case .none:
                break
        }
    }
    
    override func removeVideo() {
        super.removeVideo()
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.imageView.image = nil
        }
    }
}

// MARK: -
// MARK: Setup interface
extension CanvasView {
    override func setupLayout() {
        self.addSubview(imageView)
    }
    
    override func setupConstraints() {
        imageView.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
}

// MARK: -
// MARK: VideoViewDelegate
extension CanvasView: VideoViewDelegate {
    func videoWasLoaded() {
        self.delegate?.videoWasLoaded()
    }
}

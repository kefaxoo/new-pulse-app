//
//  PlayPauseButton.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 8.09.23.
//

import UIKit

final class PlayPauseButton: UIButton {
    private var isPlaying = false {
        didSet {
            self.setupImage()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialSetup()
    }
    
    private func initialSetup() {
        self.setupImage()
    }
    
    private func setupImage() {
        self.setImage(self.isPlaying ? Constants.Images.pause.image : Constants.Images.play.image, for: .normal)
    }
    
    func toggle() {
        self.isPlaying.toggle()
    }
    
    func changeState(_ state: Bool) {
        self.isPlaying = state
        self.setupImage()
    }
}

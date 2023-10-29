//
//  PlayPauseButton.swift
//
//
//  Created by Bahdan Piatrouski on 24.09.23.
//

import UIKit

public class PlayPauseButton: UIButton {
    private var isPlaying = false {
        didSet {
            self.setupImage()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupImage()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupImage()
    }
    
    private func setupImage() {
        self.setImage(UIImage(systemName: self.isPlaying ? "pause.fill" : "play.fill"), for: .normal)
    }
    
    public func toggle() {
        self.isPlaying.toggle()
    }
    
    public func changeState(_ state: Bool) {
        self.isPlaying = state
    }
}

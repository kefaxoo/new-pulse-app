//
//  PlayShuffleButton.swift
//
//
//  Created by Bahdan Piatrouski on 24.09.23.
//

import UIKit

public enum PlayShuffleButtonType {
    case play
    case shuffle
    case none
    
    var image: UIImage? {
        switch self {
            case .play:
                return UIImage(systemName: "play.fill")
            default:
                return nil
        }
    }
    
    var title: String {
        switch self {
            case .play:
                return "Play"
            case .shuffle:
                return "Shuffle"
            case .none:
                return ""
        }
    }
}

public class PlayShuffleButton: UIButton {
    private let type: PlayShuffleButtonType
    
    public override init(frame: CGRect) {
        self.type = .none
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        self.type = .none
        super.init(coder: coder)
    }
    
    public init(type: PlayShuffleButtonType, tintColor: UIColor) {
        self.type = type
        super.init(frame: .zero)
        self.tintColor = tintColor
    }
    
    private func initialSetup() {
        var configuration = UIButton.Configuration.tinted()
        configuration.image = self.type.image
        configuration.imagePlacement = .leading
        configuration.imagePadding = 6
        
        self.setTitle(self.type.title, for: .normal)
    }
}

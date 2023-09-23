//
//  PlaylistHeaderView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 23.09.23.
//

import UIKit

protocol PlaylistHeaderViewDelegate: AnyObject {
    func playPlaylist()
    func shufflePlaylist()
}

class PlaylistHeaderView: BaseUIView {
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    private lazy var playlistImageView: UIImageView = {
        let imageView = UIImageView.default
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var updatedLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
}

extension PlaylistHeaderView {
    override func setupLayout() {
        self.addSubview(mainStackView)
        mainStackView.addArrangedSubview(playlistImageView)
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(updatedLabel)
        mainStackView.addArrangedSubview(buttonsStackView)
    }
}

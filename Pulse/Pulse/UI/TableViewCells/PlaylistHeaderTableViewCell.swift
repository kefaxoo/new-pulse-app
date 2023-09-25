//
//  PlaylistHeaderTableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 24.09.23.
//

import UIKit
import PulseUIComponents

protocol PlaylistHeaderTableViewCellDelegate: AnyObject {
    func playPlaylist()
    func shufflePlaylist()
}

final class PlaylistHeaderTableViewCell: BaseUITableViewCell {
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
        label.text = "Playlist"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var updatedLabel: UILabel = {
        let label = UILabel()
        label.text = "Updated"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var playButton = PlayShuffleButton(type: .play, tintColor: SettingsManager.shared.color.color)
    private lazy var shuffleButton = PlayShuffleButton(type: .shuffle, tintColor: SettingsManager.shared.color.color)
    
    private var playlist: PlaylistModel?
    
    func setupCell(_ playlist: PlaylistModel) {
        self.playlist = playlist
        
        self.playlistImageView.setImage(from: playlist.image?.original)
        self.titleLabel.text = playlist.title
    }
}

// MARK: -
// MARK: Lifecycle
extension PlaylistHeaderTableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        self.playlistImageView.image = nil
        self.titleLabel.text = nil
    }
}

// MARK: -
// MARK: Setup interface methods
extension PlaylistHeaderTableViewCell {
    override func setupLayout() {
        self.contentView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(playlistImageView)
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(updatedLabel)
        mainStackView.addArrangedSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(playButton)
        buttonsStackView.addArrangedSubview(shuffleButton)
    }
    
    override func setupConstraints() {
        mainStackView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        playlistImageView.snp.makeConstraints({ $0.width.height.equalTo(200) })
    }
}

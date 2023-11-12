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
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var playlistImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.tintColor = SettingsManager.shared.color.color
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Playlist"
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var updatedLabel: UILabel = {
        let label = UILabel()
        label.text = "Updated"
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.textColor = .label.withAlphaComponent(0.7)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var playButton = PlayShuffleButton(type: .play, tintColor: SettingsManager.shared.color.color)
    private lazy var shuffleButton = PlayShuffleButton(type: .shuffle, tintColor: SettingsManager.shared.color.color)
    
    private var playlist: PlaylistModel?
    
    func setupCell(_ playlist: PlaylistModel) {
        self.playlist = playlist
        
        if playlist.image != nil {
            self.playlistImageView.setImage(from: playlist.image?.original)
        } else {
            if AppEnvironment.current.isDebug || SettingsManager.shared.localFeatures.newSoundcloud?.prod ?? false {
                PulseProvider.shared.soundcloudPlaylistArtworkV2(for: playlist) { [weak self] cover in
                    self?.playlistImageView.setImage(from: cover.xl)
                } failure: { _, _ in
                    self.playlistImageView.image = Constants.Images.warning.image
                }
            } else {
                PulseProvider.shared.soundcloudPlaylistArtwork(for: playlist) { [weak self] cover in
                    self?.playlistImageView.setImage(from: cover.xl)
                } failure: { _ in
                    self.playlistImageView.image = Constants.Images.warning.image
                }
            }
        }
        
        self.titleLabel.text = playlist.title
        self.updatedLabel.text = playlist.dateUpdated.toDateString
    }
}

// MARK: -
// MARK: Lifecycle
extension PlaylistHeaderTableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        self.playlistImageView.image = nil
        self.playlistImageView.tintColor = SettingsManager.shared.color.color
        self.titleLabel.text = nil
        self.updatedLabel.text = nil
        PulseProvider.shared.cancelTask()
    }
}

// MARK: -
// MARK: Setup interface methods
extension PlaylistHeaderTableViewCell {
    override func setupInterface() {
        super.setupInterface()
        self.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        self.selectionStyle = .none
    }
    
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
        mainStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(UIEdgeInsets(horizontal: 20))
            make.bottom.equalToSuperview().inset(20)
        }
        
        playlistImageView.snp.makeConstraints({ $0.width.height.equalTo(300) })
    }
}

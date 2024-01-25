//
//  PlaylistTableHeaderView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 15.11.23.
//

import UIKit
import PulseUIComponents

protocol PlaylistTableHeaderViewDelegate: AnyObject {
    func play()
    func shuffle()
}

final class PlaylistTableHeaderView: BaseUIView {
    private lazy var playlistImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.tintColor = SettingsManager.shared.color.color
        imageView.layer.cornerRadius = 20
        if self.playlist.image != nil {
            if self.playlist.source != .soundcloud {
                imageView.setImage(from: self.playlist.image?.original)
            } else {
                if AppEnvironment.current.isDebug || SettingsManager.shared.localFeatures.newSoundcloud?.prod ?? false {
                    PulseProvider.shared.soundcloudPlaylistArtworkV2(for: playlist) { [weak self] cover in
                        imageView.setImage(from: cover.xl)
                    } failure: { _, _ in
                        imageView.image = Constants.Images.warning.image
                    }
                } else {
                    PulseProvider.shared.soundcloudPlaylistArtwork(for: playlist) { [weak self] cover in
                        imageView.setImage(from: cover.xl)
                    } failure: { _ in
                        imageView.image = Constants.Images.warning.image
                    }
                }
            }
        }
        
        return imageView
    }()
    
    private lazy var playlistImageContentView: UIView = {
        let view = UIView(with: .clear)
        view.addSubview(playlistImageView)
        return view
    }()
    
    private(set) lazy var titleLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.text = self.playlist.title
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var updatedLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.text = self.playlist.dateUpdated.toDateString
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.textColor = .label.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.isHidden = self.playlist.dateUpdated < 0
        return label
    }()
    
    private lazy var playButton: PlayShuffleButton = {
        let button = PlayShuffleButton(type: .play, tintColor: SettingsManager.shared.color.color)
        button.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var shuffleButton: PlayShuffleButton = {
        let button = PlayShuffleButton(type: .shuffle, tintColor: SettingsManager.shared.color.color)
        button.addTarget(self, action: #selector(shuffleAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(playButton)
        stackView.addArrangedSubview(shuffleButton)
        return stackView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.addArrangedSubview(playlistImageContentView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(updatedLabel)
        stackView.addArrangedSubview(buttonsStackView)
        return stackView
    }()
    
    private let playlist: PlaylistModel
    
    weak var delegate: PlaylistTableHeaderViewDelegate?
    
    init(playlist: PlaylistModel) {
        self.playlist = playlist
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// MARK: Setup interface methods
extension PlaylistTableHeaderView {
    override func setupLayout() {
        self.addSubview(contentStackView)
    }
    
    override func setupConstraints() {
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(horizontal: 20))
            make.bottom.equalToSuperview().inset(20)
        }
        
        playlistImageView.snp.makeConstraints { make in
            make.width.height.equalTo(300)
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
    }
    
    func changeColor() {
        self.playButton.tintColor = SettingsManager.shared.color.color
        self.shuffleButton.tintColor = SettingsManager.shared.color.color
    }
}

// MARK: -
// MARK: Actions
fileprivate extension PlaylistTableHeaderView {
    @objc func playAction(_ sender: UIButton) {
        self.delegate?.play()
    }
    
    @objc func shuffleAction(_ sender: UIButton) {
        self.delegate?.shuffle()
    }
}

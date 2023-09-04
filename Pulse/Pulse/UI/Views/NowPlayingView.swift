//
//  NowPlayingView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 2.09.23.
//

import UIKit

final class NowPlayingView: BaseUIView {
    private lazy var contentView: UIView = {
        let view = UIView(with: .clear)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentNowPlayingVC)))
        return view
    }()
    
    private lazy var coverImageView: CoverImageView = {
        let imageView = CoverImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private lazy var trackInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.text = "Title"
        return label
    }()
    
    private lazy var explicitAndArtistStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        return stackView
    }()
    
    private lazy var explicitImageView: UIImageView = {
        let imageView = UIImageView.explicitImageView
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hex: "#848484")
        label.text = "Artist"
        return label
    }()
    
    private lazy var playPauseButton: PlayPauseButton = {
        let button = PlayPauseButton()
        button.addTarget(self, action: #selector(playPauseAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextTrackButton: UIButton = {
        let button = UIButton()
        button.tintColor = SettingsManager.shared.color.color
        button.setImage(UIImage(systemName: Constants.Images.System.forwardFilled), for: .normal)
        button.addTarget(self, action: #selector(nextTrackAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var durationProgressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressViewStyle = .bar
        progressView.tintColor = SettingsManager.shared.color.color
        return progressView
    }()
    
    override var tintColor: UIColor! {
        didSet {
            explicitImageView.tintColor = self.tintColor
            playPauseButton.tintColor = self.tintColor
            nextTrackButton.tintColor = self.tintColor
            durationProgressView.tintColor = self.tintColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupDelegate()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setupDelegate()
    }
    
    private func setupDelegate() {
        // TODO: setup delegate
    }
    
    func setupTrackInfo() {
        // TODO: setup track info
    }
}

// MARK: -
// MARK: Setup interface methods
extension NowPlayingView {
    override func setupLayout() {
        self.addSubview(contentView)
        contentView.addSubview(coverImageView)
        contentView.addSubview(trackInfoStackView)
        trackInfoStackView.addArrangedSubview(titleLabel)
        trackInfoStackView.addArrangedSubview(explicitAndArtistStackView)
        explicitAndArtistStackView.addArrangedSubview(explicitImageView)
        explicitAndArtistStackView.addArrangedSubview(artistLabel)
        
        contentView.addSubview(playPauseButton)
        contentView.addSubview(nextTrackButton)
        contentView.addSubview(durationProgressView)
    }
    
    override func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(55)
            make.width.equalTo(UIScreen.main.bounds.width)
        }
        
        coverImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.equalToSuperview().offset(18)
            make.bottom.equalToSuperview().inset(6)
            make.height.width.equalTo(42)
        }
        
        nextTrackButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(18)
            make.top.equalToSuperview().offset(18)
            make.bottom.equalToSuperview().inset(18)
            make.width.equalTo(30)
        }
        
        self.layoutIfNeeded()
        
        playPauseButton.snp.makeConstraints { make in
            make.trailing.equalTo(nextTrackButton.snp.leading).offset(-18)
            make.top.equalToSuperview().offset(18)
            make.bottom.equalToSuperview().inset(18)
            make.width.equalTo(16)
            make.height.equalTo(nextTrackButton.imageView?.snp.height ?? nextTrackButton.snp.height)
        }
        
        trackInfoStackView.snp.makeConstraints { make in
            make.leading.equalTo(coverImageView.snp.trailing).offset(7)
            make.trailing.equalTo(playPauseButton.snp.leading).offset(-7)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(10)
        }
        
        durationProgressView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(2)
            make.width.equalTo(UIScreen.main.bounds.width)
        }
    }
}

// MARK: -
// MARK: Actions
extension NowPlayingView {
    @objc private func playPauseAction() {
        playPauseButton.setPlaying(!playPauseButton.isPlaying)
    }
    
    @objc private func nextTrackAction(_ sender: UIButton) {
        
    }
    
    @objc private func presentNowPlayingVC() {
        
    }
}
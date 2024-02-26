//
//  NowPlayingView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 25.02.24.
//

import UIKit
import PulseUIComponents

final class NowPlayingView: BaseUIView {
    static var height: CGFloat {
        return 62
    }
    
    var height: CGFloat {
        return Self.height
    }
    
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private lazy var durationProgressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressViewStyle = .bar
        progressView.tintColor = SettingsManager.shared.color.color
        return progressView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.text = Localization.Views.NowPlaying.Label.notPlaying.localization
        label.baselineAdjustment = .none
        return label
    }()
    
    private lazy var titleMarqueeView: MarqueeView = {
        let view = titleLabel.wrapIntoMarquee()
        view.contentMargin = 10
        return view
    }()
    
    private lazy var explicitImageView: UIImageView = {
        let imageView = UIImageView.explicitImageView
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(hex: "#848484")
        return label
    }()
    
    private lazy var explicitAndArtistStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.isHidden = true
        stackView.addArrangedSubview(explicitImageView)
        stackView.addArrangedSubview(artistLabel)
        return stackView
    }()
    
    private lazy var trackInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.addArrangedSubview(titleMarqueeView)
        stackView.addArrangedSubview(explicitAndArtistStackView)
        return stackView
    }()
    
    private lazy var playPauseButton: PlayPauseButton = {
        let button = PlayPauseButton()
        button.addTarget(self, action: #selector(playPauseAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextTrackButton: UIButton = {
        let button = UIButton()
        button.tintColor = SettingsManager.shared.color.color
        button.setImage(.nextTrack)
        button.addTarget(self, action: #selector(nextTrackAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var roundedContentView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: self.traitCollection.userInterfaceStyle == .dark ? .dark : .light))
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.contentView.addSubview(coverImageView)
        view.contentView.addSubview(durationProgressView)
        view.contentView.addSubview(trackInfoStackView)
        view.contentView.addSubview(playPauseButton)
        view.contentView.addSubview(nextTrackButton)
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView(with: .clear)
        view.addSubview(roundedContentView)
        return view
    }()
    
    override var tintColor: UIColor! {
        didSet {
            durationProgressView.tintColor = self.tintColor
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.roundedContentView.effect = UIBlurEffect(style: self.traitCollection.userInterfaceStyle == .dark ? .dark : .light)
    }
}

// MARK: -
// MARK: Setup interface methods
extension NowPlayingView {
    override func setupInterface() {
        super.setupInterface()
        
        AudioPlayer.shared.viewDelegate = self
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentNowPlayingController)))
    }
    
    override func setupLayout() {
        self.addSubview(contentView)
    }
    
    override func setupConstraints() {
        contentView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        
        roundedContentView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(10)
            make.leading.trailing.top.equalToSuperview().inset(horizontal: 10)
            make.height.equalTo(52)
        }
        
        coverImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(horizontal: 10, vertical: 6)
            make.height.width.equalTo(40)
        }
        
        durationProgressView.snp.makeConstraints { make in
            make.height.equalTo(2)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        titleMarqueeView.snp.makeConstraints({ $0.height.equalTo(titleLabel.textSize.height).priority(.high) })
        
        explicitImageView.snp.makeConstraints({ $0.height.width.equalTo(explicitAndArtistStackView.snp.height) })
        
        explicitAndArtistStackView.snp.makeConstraints({ $0.height.equalTo(artistLabel.size().height) })
        
        trackInfoStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(vertical: 10)
            make.leading.equalTo(coverImageView.snp.trailing).offset(10)
            make.trailing.equalTo(playPauseButton.snp.leading).offset(-10)
        }
        
        playPauseButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(vertical: 6)
            make.width.equalTo(40)
            make.trailing.equalTo(nextTrackButton.snp.leading)
        }
        
        nextTrackButton.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(horizontal: 18, vertical: 6)
            make.width.equalTo(40)
        }
    }
}

// MARK: -
// MARK: Actions
private extension NowPlayingView {
    @objc func playPauseAction(_ sender: PlayPauseButton) {
        guard AudioPlayer.shared.track == nil else {
            AudioPlayer.shared.playPause()
            return
        }
        
        let playlist = RealmManager<LibraryTrackModel>().read().reversed().map({ $0.trackModel })
        guard !playlist.isEmpty else { return }
        
        AudioPlayer.shared.play(from: playlist[0], playlist: playlist, position: 0, isNewPlaylist: true)
    }
    
    @objc func nextTrackAction(_ sender: UIButton) {
        guard AudioPlayer.shared.track != nil else { return }
        
        AudioPlayer.shared.nextTrack()
    }
    
    @objc func presentNowPlayingController(_ sender: UITapGestureRecognizer) {
        MainCoordinator.shared.presentNowPlayingController()
    }
}

// MARK: -
// MARK: AudioPlayerViewDelegate
extension NowPlayingView: AudioPlayerViewDelegate {
    func updateDuration(_ duration: Float) {
        self.durationProgressView.progress = duration
    }
    
    func changeState(isPlaying: Bool) {
        self.playPauseButton.changeState(isPlaying)
    }
    
    func resetView() {
        self.titleLabel.text = Localization.Views.NowPlaying.Label.notPlaying.localization
        self.titleMarqueeView.reloadData()
        self.explicitAndArtistStackView.isHidden = true
        self.coverImageView.image = nil
        self.explicitImageView.isHidden = true
    }
    
    func setupCover(_ cover: UIImage?) {
        self.coverImageView.image = cover
    }
    
    func setupTrackInfo(_ track: TrackModel) {
        self.titleLabel.text = track.title
        self.titleMarqueeView.reloadData()
        self.artistLabel.text = track.artistText
        self.explicitAndArtistStackView.isHidden = track.artistText.isEmpty
        self.explicitImageView.isHidden = !track.isExplicit
    }
}

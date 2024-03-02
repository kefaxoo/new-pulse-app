//
//  NowPlayingView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 2.09.23.
//

import UIKit
import PulseUIComponents

final class NowPlayingView: BaseUIView {
    static let height: CGFloat = 55
    
    private lazy var contentView: UIView = {
        let view = UIView(with: .clear)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentNowPlayingVC)))
        return view
    }()
    
    private lazy var coverImageView: UIImageView = {
        let coverImageView = UIImageView.default
        coverImageView.layer.cornerRadius = 10
        return coverImageView
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
        label.text = Localization.Views.NowPlaying.Label.notPlaying.localization
        label.baselineAdjustment = .none
        return label
    }()
    
    private lazy var titleMarqueeView: MarqueeView = {
        let view = MarqueeView()
        view.contentView = self.titleLabel
        view.contentMargin = 10
        view.pointsPerFrame = 0.1
        view.marqueeType = .reverse
        return view
    }()
    
    private lazy var explicitAndArtistStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.isHidden = true
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
        button.setImage(Constants.Images.nextTrack.image, for: .normal)
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
        AudioPlayer.shared.viewDelegate = self
    }
}

// MARK: -
// MARK: Setup interface methods
extension NowPlayingView {
    override func setupLayout() {
        self.addSubview(contentView)
        contentView.addSubview(coverImageView)
        contentView.addSubview(trackInfoStackView)
        trackInfoStackView.addArrangedSubview(titleMarqueeView)
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
            make.height.equalTo(NowPlayingView.height)
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
        
        titleLabel.snp.makeConstraints({ $0.height.equalTo(titleLabel.textSize.height).priority(.required) })
        titleMarqueeView.snp.makeConstraints({ $0.height.equalTo(titleLabel.textSize.height).priority(.required) })
        
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
            make.height.equalTo(2)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: -
// MARK: Actions
extension NowPlayingView {
    @objc private func playPauseAction() {
        if AudioPlayer.shared.track == nil {
            let playlist = RealmManager<LibraryTrackModel>().read().map({ TrackModel($0) }).sorted
            guard !playlist.isEmpty else { return }
            
            AudioPlayer.shared.play(from: playlist[0], playlist: playlist, position: 0, isNewPlaylist: true)
            return
        }
        
        AudioPlayer.shared.playPause()
    }
    
    @objc private func nextTrackAction(_ sender: UIButton) {
        guard AudioPlayer.shared.track != nil else { return }
        
        AudioPlayer.shared.nextTrack()
    }
    
    @objc private func presentNowPlayingVC() {
        guard AppEnvironment.current.isDebug || SettingsManager.shared.localFeatures.nowPlayingVC?.prod ?? false else { return }
        
        MainCoordinator.shared.presentNowPlayingController()
    }
}

// MARK: -
// MARK: AudioPlayerViewDelegate
extension NowPlayingView: AudioPlayerViewDelegate {
    func setupTrackInfo(_ track: TrackModel) {
        self.titleLabel.text = track.title
        self.titleMarqueeView.reloadData()
        self.artistLabel.text = track.artistText
        self.explicitAndArtistStackView.isHidden = track.artistText.isEmpty
    }
    
    func setupCover(_ cover: UIImage?) {
        self.coverImageView.setImage(cover)
    }
    
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
    }
}

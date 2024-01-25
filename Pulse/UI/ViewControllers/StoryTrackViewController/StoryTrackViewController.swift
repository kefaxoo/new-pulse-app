//
//  StoryTrackViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.01.24.
//

import UIKit
import PulseUIComponents

final class StoryTrackViewController: BaseUIViewController {
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.layer.cornerRadius = 20
        imageView.setImage(from: track.image?.original)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = self.track.title
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.text = self.track.artistText
        label.textColor = .white
        return label
    }()
    
    private lazy var previousTrackButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Constants.Images.previousTrack.image?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.tintColor = SettingsManager.shared.color.color
        button.imageView?.contentMode = .scaleAspectFill
//        button.addTarget(self, action: #selector(previousTrackAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.setImage(
            (AudioPlayer.shared.isPlaying ? Constants.Images.pause : Constants.Images.play).image?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 30)),
            for: .normal
        )
        
        button.tintColor = SettingsManager.shared.color.color
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(playPauseAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextTrackButton: UIButton = {
        let button = UIButton()
        button.setImage(Constants.Images.nextTrack.image?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        button.tintColor = SettingsManager.shared.color.color
        button.imageView?.contentMode = .scaleAspectFill
//        button.addTarget(self, action: #selector(nextTrackAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var controlStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.addArrangedSubview(previousTrackButton)
        stackView.addArrangedSubview(playPauseButton)
        stackView.addArrangedSubview(nextTrackButton)
        return stackView
    }()
    
    private lazy var playerContentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 12
        stackView.axis = .vertical
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(artistLabel)
        stackView.addArrangedSubview(controlStackView)
        return stackView
    }()
    
    private lazy var playerContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.7)
        view.layer.cornerRadius = 10
        view.addSubview(playerContentStackView)
        return view
    }()
    
    private lazy var durationProgressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressViewStyle = .bar
        progressView.tintColor = SettingsManager.shared.color.color
        return progressView
    }()
    
    private lazy var swipeGesture: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(swipeDismissAction))
    }()
    
    private let track: TrackModel
    private let story: PulseStory
    private let completion: (() -> ())?
    
    init(track: TrackModel, story: PulseStory, completion: (() -> ())?) {
        self.track = track
        self.story = story
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
        self.view.backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureSwipe()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !story.didUserWatch {
            PulseProvider.shared.markStoryAsWatched(storyId: story.id)
        }
        
        self.completion?()
        AudioPlayer.shared.controllerDelegate = self
        AudioPlayer.shared.play(from: self.track, playlist: [self.track], position: 0, isNewPlaylist: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        AudioPlayer.shared.cleanPlayerFromStory()
    }
    
    private func configureSwipe() {
        self.view.addGestureRecognizer(self.swipeGesture)
    }
    
    @objc private func swipeDismissAction(_ sender: UIPanGestureRecognizer) {
        let percentThreshold: CGFloat = 0.3
        let translation = sender.translation(in: view)
        
        let newY = ensureRange(value: view.frame.minY + translation.y, minimum: 0, maximum: view.frame.maxY)
        let progress = progressAlongAxis(newY, view.frame.height)
        
        view.frame.origin.y = newY // Move view to new position

        if sender.state == .ended {
            let velocity = sender.velocity(in: view)
            if velocity.y >= self.view.frame.height / 2 || progress > percentThreshold {
                self.dismiss(animated: true) // Perform dismiss
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.frame.origin.y = 0 // Revert animation
                })
            }
        }
        
        sender.setTranslation(.zero, in: view)
    }
    
    @objc private func playPauseAction(_ sender: UIButton) {
        AudioPlayer.shared.playPause()
        sender.setImage(
            (AudioPlayer.shared.isPlaying ? Constants.Images.pause : Constants.Images.play)
                .image?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30)),
            for: .normal
        )
    }
}

// MARK: -
// MARK: Setup interface methods
extension StoryTrackViewController {
    override func setupLayout() {
        self.view.addSubview(backgroundImageView)
        self.view.addSubview(playerContentView)
        self.view.addSubview(durationProgressView)
    }
    
    override func setupConstraints() {
        backgroundImageView.snp.makeConstraints({ $0.edges.equalTo(MainCoordinator.shared.safeAreaInsets) })
        
        playerContentView.snp.makeConstraints { make in
            make.bottom.equalTo(self.backgroundImageView.snp.bottom).offset(-30)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(horizontal: 20))
        }
        
        playerContentStackView.snp.makeConstraints({ $0.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: 10, vertical: 10)) })
        
        durationProgressView.snp.makeConstraints { make in
            make.bottom.equalTo(backgroundImageView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(3)
        }
    }
}

extension StoryTrackViewController: AudioPlayerControllerDelegate {
    func updateDuration(_ duration: Float, currentTime: Float) {
        self.durationProgressView.progress = currentTime / duration
    }
    
    func updateVolume(_ volume: Float) {}
    
    func shouldFetchCanvas() {}
    
    func trackIsReadyToPlay() {
        self.playPauseButton.setImage(
            (AudioPlayer.shared.isPlaying ? Constants.Images.pause : Constants.Images.play).image?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 30)),
            for: .normal
        )
    }
    
    func setupCover(_ cover: UIImage?) {}
    
    func setupTrackInfo(_ track: TrackModel) {}
    
    func trackDidFinishPlaying() {
        self.dismiss(animated: true)
    }
}

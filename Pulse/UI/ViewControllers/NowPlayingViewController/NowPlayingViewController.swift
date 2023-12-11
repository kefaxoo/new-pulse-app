//
//  NowPlayingViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 13.09.23.
//

import UIKit
import SliderControl
import AVKit

final class NowPlayingViewController: BaseUIViewController {
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(Constants.Images.dismissNowPlaying.image, for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.text = "Title"
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var artistButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label.withAlphaComponent(0.7), for: .normal)
        button.contentHorizontalAlignment = .left
        button.setTitle("Artist", for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.showsMenuAsPrimaryAction = true
        if let artist = self.artist {
            button.menu = self.actionsManager.artistNowPlayingActions(artist)
        }
        
        return button
    }()
    
    private lazy var trackInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(artistButton)
        return stackView
    }()
    
    private lazy var actionsButton: UIButton = {
        let button = UIButton()
        button.setImage(Constants.Images.actionsNowPlaying.image, for: .normal)
        button.tintColor = .label.withAlphaComponent(0.7)
        var configuration = UIButton.Configuration.plain()
        configuration.preferredSymbolConfigurationForImage = .init(font: .systemFont(ofSize: 17), scale: .large)
        configuration.imagePlacement = .trailing
        button.configuration = configuration
        button.showsMenuAsPrimaryAction = true
        if let track = self.track {
            button.menu = self.actionsManager.trackActions(track, shouldReverseActions: true)
        }
        
        return button
    }()
    
    private lazy var trackInfoHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.addArrangedSubview(trackInfoStackView)
        stackView.addArrangedSubview(actionsButton)
        return stackView
    }()
    
    private lazy var durationSlider: SliderControl = {
        let slider = SliderControl()
        slider.delegate = self
        slider.tag = 1001
        slider.defaultProgressColor = SettingsManager.shared.color.color
        slider.enlargedProgressColor = SettingsManager.shared.color.color
        slider.value = Float(AudioPlayer.shared.duration ?? 0)
        return slider
    }()
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.text = "--:--"
        return label
    }()
    
    private lazy var leftTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.text = "--:--"
        return label
    }()
    
    private lazy var durationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.addArrangedSubview(currentTimeLabel)
        stackView.addArrangedSubview(.spacer)
        stackView.addArrangedSubview(leftTimeLabel)
        return stackView
    }()
    
    private lazy var previousTrackButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Constants.Images.previousTrack.image?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 40)), for: .normal)
        button.tintColor = SettingsManager.shared.color.color
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(previousTrackAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.setImage(Constants.Images.pause.image?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 40)), for: .normal)
        button.tintColor = SettingsManager.shared.color.color
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(playPauseAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextTrackButton: UIButton = {
        let button = UIButton()
        button.setImage(Constants.Images.nextTrack.image?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 40)), for: .normal)
        button.tintColor = SettingsManager.shared.color.color
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(nextTrackAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var controlStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.addArrangedSubview(previousTrackButton)
        stackView.addArrangedSubview(playPauseButton)
        stackView.addArrangedSubview(nextTrackButton)
        return stackView
    }()
    
    private lazy var muteImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.image = Constants.Images.minVolume.image
        imageView.tintColor = SettingsManager.shared.color.color
        return imageView
    }()
    
    private lazy var volumeSlider: SliderControl = {
        let slider = SliderControl()
        slider.delegate = self
        slider.tag = 1002
        slider.defaultProgressColor = SettingsManager.shared.color.color
        slider.enlargedProgressColor = SettingsManager.shared.color.color
        slider.value = AudioPlayer.shared.currentVolume
        return slider
    }()
    
    private lazy var maxVolumeImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.image = Constants.Images.maxVolume.image
        imageView.tintColor = SettingsManager.shared.color.color
        return imageView
    }()
    
    private lazy var volumeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.addArrangedSubview(self.muteImageView)
        stackView.addArrangedSubview(self.volumeSlider)
        stackView.addArrangedSubview(self.maxVolumeImageView)
        return stackView
    }()
    
    private lazy var routePickerView: AVRoutePickerView = {
        let avRoutePickerView = AVRoutePickerView()
        avRoutePickerView.tintColor = SettingsManager.shared.color.color
        avRoutePickerView.activeTintColor = SettingsManager.shared.color.color
        return avRoutePickerView
    }()
    
    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.addArrangedSubview(routePickerView)
        return stackView
    }()
    
    private lazy var contentVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.addArrangedSubview(self.coverImageView)
        stackView.addArrangedSubview(self.trackInfoHorizontalStackView)
        stackView.addArrangedSubview(self.durationSlider)
        stackView.addArrangedSubview(self.durationStackView)
        stackView.addArrangedSubview(self.controlStackView)
        stackView.addArrangedSubview(self.volumeStackView)
        stackView.addArrangedSubview(self.bottomStackView)
        return stackView
    }()
    
    private lazy var presenter: NowPlayingPresenter = {
        let presenter = NowPlayingPresenter()
        presenter.delegate = self
        return presenter
    }()
    
    private lazy var swipeGesture: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(swipeDismissAction))
    }()
    
    private lazy var actionsManager: ActionsManager = { return ActionsManager(self)
    }()
    
    private var track: TrackModel? {
        return AudioPlayer.shared.track
    }
    
    private var artist: ArtistModel? {
        return self.track?.artist
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
        
        AudioPlayer.shared.controllerDelegate = self
        AudioPlayer.shared.observeSystemVolume()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        AudioPlayer.shared.controllerDelegate = nil
        AudioPlayer.shared.removeSystemVolumeObserver()
    }
}

// MARK: -
// MARK: Lifecycle
extension NowPlayingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        self.configureSwipe()
    }
}

// MARK: -
// MARK: Setup interface methods
extension NowPlayingViewController {
    override func setupLayout() {
        self.view.addSubview(dismissButton)
        self.view.addSubview(contentVerticalStackView)
    }
    
    override func setupConstraints() {
        dismissButton.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(MainCoordinator.shared.safeAreaInsets.top + 10)
            make.width.equalToSuperview()
        }

        contentVerticalStackView.snp.makeConstraints { make in
            make.top.equalTo(self.dismissButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(horizontal: 20))
            make.bottom.equalTo(MainCoordinator.shared.safeAreaInsets.bottom).offset(-30)
        }
        
        coverImageView.snp.makeConstraints({ $0.height.width.equalTo(contentVerticalStackView.snp.width) })
        
        trackInfoHorizontalStackView.snp.makeConstraints({
            $0.height.equalTo(trackInfoStackView.spacing + titleLabel.textSize.height + (artistButton.titleLabel?.textSize.height ?? 0))
        })
        
        titleLabel.snp.makeConstraints({ $0.height.equalTo(titleLabel.textSize.height) })
        artistButton.snp.makeConstraints({ $0.height.equalTo(artistButton.titleLabel?.textSize.height ?? 0) })
        
        actionsButton.snp.makeConstraints({ $0.width.equalTo(trackInfoHorizontalStackView.snp.height) })
        
        durationStackView.snp.makeConstraints({ $0.height.equalTo(currentTimeLabel.textSize.height) })
        
        volumeStackView.snp.makeConstraints({ $0.height.equalTo(20) })
        
        bottomStackView.snp.makeConstraints({ $0.height.equalTo(30) })
    }
    
    private func setupDuration(_ duration: Float, currentTime: Float) {
        currentTimeLabel.text = currentTime.toMinuteAndSeconds
        leftTimeLabel.text = "-\((duration - currentTime).toMinuteAndSeconds)"
    }
    
    private func configureSwipe() {
        self.view.addGestureRecognizer(self.swipeGesture)
    }
    
    private func removeSwipe() {
        self.view.removeGestureRecognizer(self.swipeGesture)
    }
}

// MARK: -
// MARK: NowPlayingPresenterDelegate
extension NowPlayingViewController: NowPlayingPresenterDelegate {
    func setCover(_ cover: UIImage?) {
        self.coverImageView.image = cover
    }
    
    func setTrack(_ track: TrackModel) {
        self.titleLabel.text = track.title
        self.artistButton.setTitle(track.artistText, for: .normal)
        self.actionsButton.menu = actionsManager.trackActions(track, shouldReverseActions: true)
        if let artist = track.artist {
            self.artistButton.menu = actionsManager.artistNowPlayingActions(artist)
        }
    }
}

// MARK: -
// MARK: Actions
extension NowPlayingViewController {
    @objc private func dismissAction(_ sender: UIButton) {
        self.dismiss(animated: true)
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
    
    @objc private func previousTrackAction(_ sender: UIButton) {
        _ = AudioPlayer.shared.previousTrack()
    }
    
    @objc private func playPauseAction(_ sender: UIButton) {
        _ = AudioPlayer.shared.playPause()
        sender.setImage(
            (AudioPlayer.shared.isPlaying ? Constants.Images.pause : Constants.Images.play)
                .image?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 40)),
            for: .normal
        )
    }
    
    @objc private func nextTrackAction(_ sender: UIButton) {
        _ = AudioPlayer.shared.nextTrack()
    }
}

// MARK: -
// MARK: AudioPlayerControllerDelegate
extension NowPlayingViewController: AudioPlayerControllerDelegate {
    func setupCover(_ cover: UIImage?) {
        self.coverImageView.image = cover
    }
    
    func setupTrackInfo(_ track: TrackModel) {
        self.titleLabel.text = track.title
        self.artistButton.setTitle(track.artistText, for: .normal)
    }
    
    func updateDuration(_ duration: Float, currentTime: Float) {
        durationSlider.value = currentTime / duration
        self.setupDuration(duration, currentTime: currentTime)
    }
    
    func updateVolume(_ volume: Float) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.volumeSlider.value = volume
            self?.volumeSlider.layoutIfNeeded()
        }
    }
}

// MARK: -
// MARK: SliderControlDelegate
extension NowPlayingViewController: SliderControlDelegate {
    func valueBeganChange(_ value: Float, tag: Int) {
        if tag == self.durationSlider.tag {
            AudioPlayer.shared.isDurationChanging = true
        }
        
        self.removeSwipe()
    }
    
    func valueChanging(_ value: Float, tag: Int) {
        if tag == self.durationSlider.tag {
            guard let doubleDuration = AudioPlayer.shared.duration else { return }
            
            let duration = Float(doubleDuration)
            self.setupDuration(duration, currentTime: value * duration)
        } else if tag == self.volumeSlider.tag {
            AudioPlayer.shared.setVolume(value)
        }
    }
    
    func valueDidChange(_ value: Float, tag: Int) {
        if tag == self.durationSlider.tag {
            AudioPlayer.shared.isDurationChanging = false
            AudioPlayer.shared.updateTimePosition(value)
        } else if tag == self.volumeSlider.tag {
            AudioPlayer.shared.setVolume(value)
        }
        
        self.configureSwipe()
    }
    
    func valueDidNotChange(tag: Int) {
        self.configureSwipe()
    }
}

// MARK: -
// MARK: ActionsManagerDelegate
extension NowPlayingViewController: ActionsManagerDelegate {
    func updateButtonMenu() {
        guard let track else { return }
        
        actionsButton.menu = actionsManager.trackActions(track, shouldReverseActions: true)
    }
}

@available(iOS 17.0, *)
#Preview {
    let vc = NowPlayingViewController()
    return vc
}

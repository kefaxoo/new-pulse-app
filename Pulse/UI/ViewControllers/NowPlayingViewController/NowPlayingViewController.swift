//
//  NowPlayingViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 13.09.23.
//

import UIKit
import SliderControl
import AVKit
import PulseUIComponents

final class NowPlayingViewController: BaseUIViewController {
    private lazy var canvasView: CanvasView = {
        let view = CanvasView()
        view.delegate = self
        return view
    }()
    
    private lazy var canvasSubstrateView: UIView = {
        let view = UIView(with: .black.withAlphaComponent(0.5))
        view.isHidden = true
        return view
    }()
    
    private lazy var artistInfoView: NowPlayingArtistInfoView = {
        let view = NowPlayingArtistInfoView()
        view.artist = AudioPlayer.shared.track?.artist
        view.configureTapClosure { [weak self] in
            guard let artist = AudioPlayer.shared.track?.artist,
                  Constants.isDebug
            else { return }
            
            self?.dismiss(animated: true, completion: {
                MainCoordinator.shared.pushArtistViewController(artist: artist)
            })
        }
        
        view.isHidden = true
        return view
    }()
    
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
    
    private lazy var artistButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label.withAlphaComponent(0.7), for: .normal)
        button.contentHorizontalAlignment = .left
        button.setTitle("Artist", for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.showsMenuAsPrimaryAction = true
        button.titleLabel?.font = .systemFont(ofSize: 15)
        if let artist = self.artist {
            button.menu = self.actionsManager.artistNowPlayingActions(artist)
        }
        
        return button
    }()
    
    private lazy var artistMarqueeView: MarqueeView = {
        return self.artistButton.wrapIntoMarquee()
    }()
    
    private lazy var actionsButton: UIButton = {
        let button = UIButton()
        button.setImage(Constants.Images.actionsNowPlaying.image, for: .normal)
        button.tintColor = SettingsManager.shared.color.color
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
    
    private lazy var trackInfoView: UIView = {
        let view = UIView(with: .clear)
        view.addSubview(titleMarqueeView)
        view.addSubview(artistMarqueeView)
        view.addSubview(actionsButton)
        return view
    }()
    
    private lazy var durationSlider: SliderControl = {
        let slider = SliderControl()
        slider.delegate = self
        slider.tag = 1001
        slider.defaultProgressColor = SettingsManager.shared.color.color
        slider.enlargedProgressColor = SettingsManager.shared.color.color
        slider.value = 0
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
        button.setImage(
            (AudioPlayer.shared.isPlaying ? Constants.Images.pause : Constants.Images.play).image?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 40)),
            for: .normal
        )
        
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
        stackView.addArrangedSubview(self.trackInfoView)
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
    
    private lazy var actionsManager: ActionsManager = { 
        return ActionsManager(self)
    }()
    
    private var track: TrackModel? {
        return AudioPlayer.shared.track
    }
    
    private var artist: ArtistModel? {
        return self.track?.artist
    }
    
    private lazy var canvasTapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(didTapAction))
    }()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.durationSlider.isUserInteractionEnabled = AudioPlayer.shared.isTrackLoaded
        guard AudioPlayer.shared.isTrackLoaded else { return }
        
        shouldFetchCanvas()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.statusBarStyle = .default
        self.overrideUserInterfaceStyle = SettingsManager.shared.appearance.userIntefaceStyle
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.canvasView.removeVideo()
    }
}

// MARK: -
// MARK: Setup interface methods
extension NowPlayingViewController {
    override func setupInterface() {
        super.setupInterface()
        self.changeCoverSize(isSmall: !AudioPlayer.shared.isPlaying)
        self.setupDuration(Float(AudioPlayer.shared.duration ?? 0), currentTime: Float(AudioPlayer.shared.currentTime ?? 0))
    }
    
    override func setupLayout() {
        self.view.addSubview(canvasView)
        self.view.addSubview(canvasSubstrateView)
        self.view.addSubview(artistInfoView)
        self.view.addSubview(dismissButton)
        self.view.addSubview(contentVerticalStackView)
    }
    
    override func setupConstraints() {
        canvasView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        canvasSubstrateView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        
        artistInfoView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(60 + MainCoordinator.shared.safeAreaInsets.bottom)
        }
        
        dismissButton.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(MainCoordinator.shared.safeAreaInsets.top + 10)
            make.width.equalToSuperview()
        }

        contentVerticalStackView.snp.makeConstraints { make in
            make.top.equalTo(self.dismissButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(horizontal: 30))
            make.bottom.equalTo(MainCoordinator.shared.safeAreaInsets.bottom).offset(-30)
        }
        
        coverImageView.snp.makeConstraints({ $0.height.width.equalTo(contentVerticalStackView.snp.width) })
        
        titleMarqueeView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.trailing.equalTo(actionsButton.snp.leading).offset(-20)
            make.height.equalTo(titleLabel.textSize.height)
        }
        
        artistMarqueeView.snp.makeConstraints { make in
            make.bottom.leading.equalToSuperview()
            make.top.equalTo(titleMarqueeView.snp.bottom).offset(8)
            make.trailing.equalTo(actionsButton.snp.leading).offset(-20)
            make.height.equalTo(artistButton.titleLabel?.textSize.height ?? 0)
        }
        
        actionsButton.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(trackInfoView.snp.height)
        }
        
        trackInfoView.snp.makeConstraints({
            $0.height.equalTo(8 + titleLabel.textSize.height + (artistButton.titleLabel?.textSize.height ?? 0))
        })
        
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
    
    private func configureTap() {
        self.view.addGestureRecognizer(self.canvasTapGesture)
    }
    
    private func removeTap() {
        self.view.removeGestureRecognizer(self.canvasTapGesture)
    }
    
    private func changeCoverSize(isSmall: Bool) {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut) { [weak self] in
            if isSmall {
                self?.coverImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            } else {
                self?.coverImageView.transform = .identity
            }
        }
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
        
        self.titleMarqueeView.reloadData()
        self.artistMarqueeView.reloadData()
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fetchArtistIfNeeded), object: nil)
        perform(#selector(fetchArtistIfNeeded), with: nil)
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
        AudioPlayer.shared.previousTrack()
        self.trackDidChanged()
    }
    
    @objc private func playPauseAction(_ sender: UIButton) {
        AudioPlayer.shared.playPause()
        sender.setImage(
            (AudioPlayer.shared.isPlaying ? Constants.Images.pause : Constants.Images.play)
                .image?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 40)),
            for: .normal
        )
        
        self.changeCoverSize(isSmall: !AudioPlayer.shared.isPlaying)
    }
    
    @objc private func nextTrackAction(_ sender: UIButton) {
        AudioPlayer.shared.nextTrack()
        self.trackDidChanged()
    }
    
    @objc private func didTapAction(_ sender: UITapGestureRecognizer) {
        guard self.canvasView.isCanvasLoaded,
              !AudioPlayer.shared.isVolumeChanging,
              !AudioPlayer.shared.isDurationChanging
        else { return }
        
        self.contentVerticalStackView.smoothIsHiddenAfterAlpha.toggle()
        self.canvasSubstrateView.smoothIsHidden.toggle()
        self.artistInfoView.smoothIsHidden.toggle()
    }
    
    func trackDidChanged() {
        self.durationSlider.isUserInteractionEnabled = false
        self.durationSlider.value = 0
        self.leftTimeLabel.text = "--:--"
        self.currentTimeLabel.text = "--:--"
    }
}

// MARK: -
// MARK: AudioPlayerControllerDelegate
extension NowPlayingViewController: AudioPlayerControllerDelegate {
    func setupCover(_ cover: UIImage?) {
        self.setCover(cover)
    }
    
    func setupTrackInfo(_ track: TrackModel) {
        // Canvas
        self.canvasSubstrateView.smoothIsHidden = true
        self.artistInfoView.smoothIsHidden = true
        self.contentVerticalStackView.smoothIsHiddenAfterAlpha = false
        self.coverImageView.smoothIsHiddenWithAlpha = false
        self.trackDidChanged()
        self.removeTap()
        self.canvasView.removeVideo()
        self.overrideUserInterfaceStyle = SettingsManager.shared.appearance.userIntefaceStyle
        self.statusBarStyle = .default
        self.artistInfoView.artist = track.artist
        
        self.titleLabel.text = track.title
        self.artistButton.setTitle(track.artistText, for: .normal)
        self.titleMarqueeView.reloadData()
        self.artistMarqueeView.reloadData()
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fetchArtistIfNeeded), object: nil)
        perform(#selector(fetchArtistIfNeeded), with: nil)
    }
    
    @objc func fetchArtistIfNeeded() {
        guard let track = AudioPlayer.shared.track,
              let artist = track.artist,
              track.service == .deezer
        else { return }
        
        DeezerProvider.shared.fetchArtistInfo(for: artist) { [weak self] artist in
            self?.artistInfoView.artist = artist
        }
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
    
    func shouldFetchCanvas() {
        CanvasManager.shared.fetchCanvasForCurrentTrack { [weak self] link, canvasType in
            self?.canvasView.setCanvas(from: link, canvasType: canvasType)
        }
    }
    
    func trackIsReadyToPlay() {
        self.playPauseButton.setImage(
            (AudioPlayer.shared.isPlaying ? Constants.Images.pause : Constants.Images.play).image?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 40)),
            for: .normal
        )
        
        self.durationSlider.isUserInteractionEnabled = true
        self.changeCoverSize(isSmall: !AudioPlayer.shared.isPlaying)
        shouldFetchCanvas()
    }
}

// MARK: -
// MARK: SliderControlDelegate
extension NowPlayingViewController: SliderControlDelegate {
    func valueBeganChange(_ value: Float, tag: Int) {
        if tag == self.durationSlider.tag {
            AudioPlayer.shared.isDurationChanging = true
        } else if tag == self.volumeSlider.tag {
            AudioPlayer.shared.isVolumeChanging = true
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
            AudioPlayer.shared.isVolumeChanging = false
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

// MARK: -
// MARK: CanvasViewDelegate
extension NowPlayingViewController: CanvasViewDelegate {
    func videoWasLoaded() {
        self.coverImageView.smoothIsHiddenWithAlpha = true
        self.canvasView.smoothIsHiddenWithAlpha = false
        self.canvasSubstrateView.isHidden = false
        self.overrideUserInterfaceStyle = .dark
        self.statusBarStyle = .lightContent
        self.configureTap()
    }
}

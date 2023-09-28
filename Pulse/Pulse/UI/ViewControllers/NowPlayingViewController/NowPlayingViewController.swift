//
//  NowPlayingViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 13.09.23.
//

import UIKit
import SliderControl

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
    
    private lazy var trackInfoHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        return stackView
    }()
    
    private lazy var trackInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private lazy var artistButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label.withAlphaComponent(0.7), for: .normal)
        var configuration = UIButton.Configuration.plain()
        configuration.titleAlignment = .leading
        button.configuration = configuration
        return button
    }()
    
    private lazy var actionsButton: UIButton = {
        let button = UIButton()
        button.setImage(Constants.Images.actionsNowPlaying.image, for: .normal)
        button.tintColor = .label.withAlphaComponent(0.7)
        var configuration = UIButton.Configuration.plain()
        configuration.preferredSymbolConfigurationForImage = .init(font: .systemFont(ofSize: 17), scale: .large)
        configuration.imagePlacement = .trailing
        button.configuration = configuration
        return button
    }()
    
    private lazy var durationSlider: SliderControl = {
        let slider = SliderControl()
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
    
    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    private lazy var audioDestinationButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.plain()
        configuration.image = Constants.Images.audioDestination.image
        configuration.preferredSymbolConfigurationForImage = .init(font: .systemFont(ofSize: 17), scale: .large)
        button.configuration = configuration
        button.tintColor = SettingsManager.shared.color.color
        return button
    }()
    
    private lazy var presenter: NowPlayingPresenter = {
        let presenter = NowPlayingPresenter()
        presenter.delegate = self
        return presenter
    }()
    
    private lazy var swipeGesture: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(swipeDismissAction))
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
        
        AudioPlayer.shared.nowPlayingViewControllerDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        AudioPlayer.shared.nowPlayingViewControllerDelegate = nil
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
        self.view.addSubview(coverImageView)
        self.view.addSubview(trackInfoHorizontalStackView)
        trackInfoHorizontalStackView.addArrangedSubview(trackInfoStackView)
        trackInfoStackView.addArrangedSubview(titleLabel)
        trackInfoStackView.addArrangedSubview(artistButton)
        trackInfoHorizontalStackView.addArrangedSubview(actionsButton)
        
        self.view.addSubview(durationSlider)
        self.view.addSubview(currentTimeLabel)
        self.view.addSubview(leftTimeLabel)
        
        self.view.addSubview(bottomStackView)
        bottomStackView.addArrangedSubview(audioDestinationButton)
    }
    
    override func setupConstraints() {
        dismissButton.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(MainCoordinator.shared.safeAreaInsets.top + 10)
            make.width.equalToSuperview()
        }
        
        coverImageView.snp.makeConstraints { make in
            make.top.equalTo(self.dismissButton.snp.bottom).offset(20)
            make.height.width.equalTo(self.view.frame.width - 40)
            make.centerX.equalToSuperview()
        }
        
        trackInfoHorizontalStackView.snp.makeConstraints { make in
            make.top.equalTo(self.coverImageView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(trackInfoStackView.spacing + titleLabel.textSize.height + (artistButton.titleLabel?.textSize.height ?? 0))
        }
        
        titleLabel.snp.makeConstraints({ $0.height.equalTo(titleLabel.textSize.height) })
        artistButton.snp.makeConstraints({ $0.height.equalTo(artistButton.titleLabel?.textSize.height ?? 0) })
        
        actionsButton.snp.makeConstraints({ $0.width.equalTo(trackInfoHorizontalStackView.snp.height) })
        
        durationSlider.snp.makeConstraints { make in
            make.top.equalTo(trackInfoHorizontalStackView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        currentTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(self.durationSlider.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
        }
        
        leftTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(self.durationSlider.snp.bottom).offset(10)
            make.trailing.equalToSuperview().inset(20)
        }
        
        bottomStackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(MainCoordinator.shared.safeAreaInsets.bottom + 20)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(20)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).inset(20)
            make.height.equalTo(30)
        }
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
}

// MARK: -
// MARK: AudioPlayerNowPlayingViewControllerDelegate
extension NowPlayingViewController: AudioPlayerNowPlayingControllerDelegate {
    func setupCover(_ cover: UIImage?) {
        self.coverImageView.image = cover
    }
    
    func setupTrackInfo(_ track: TrackModel) {
        self.titleLabel.text = track.title
        self.artistButton.setTitle(track.artistText, for: .normal)
    }
    
    func updateDuration(_ duration: Float, currentTime: Float) {
        durationSlider.value = currentTime / duration
    }
}

// MARK: -
// MARK: SliderControlDelegate
extension NowPlayingViewController: SliderControlDelegate {
    func valueStartedChange(_ value: Float) {
        AudioPlayer.shared.isDurationChanging = true
        self.removeSwipe()
    }
    
    func valueDidChange(_ value: Float) {
        AudioPlayer.shared.isDurationChanging = false
        AudioPlayer.shared.updateTimePosition(value)
        self.configureSwipe()
    }
    
    func valueDidNotChange() {
        self.configureSwipe()
    }
}

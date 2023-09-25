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
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .equalSpacing
        return stackView
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
        stackView.spacing = 8
        stackView.distribution = .fill
        return stackView
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
        return button
    }()
    
    private lazy var actionsButton: UIButton = {
        let button = UIButton()
        button.setImage(Constants.Images.actionsNowPlaying.image, for: .normal)
        button.tintColor = .label.withAlphaComponent(0.7)
        return button
    }()
    
    private lazy var durationSlider: SliderControl = {
        let slider = SliderControl()
        slider.delegate = self
        slider.defaultProgressColor = SettingsManager.shared.color.color
        slider.enlargedProgressColor = SettingsManager.shared.color.color
        return slider
    }()
    
    private lazy var durationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.text = "--:--"
        return label
    }()
    
    private lazy var durationSpacer = UIView.spacer
    
    private lazy var leftTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.text = "--:--"
        return label
    }()
    
    private lazy var presenter: NowPlayingPresenter = {
        let presenter = NowPlayingPresenter()
        presenter.delegate = self
        return presenter
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        
        AudioPlayer.shared.controllerDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        AudioPlayer.shared.controllerDelegate = nil
    }
}

// MARK: -
// MARK: Lifecycle
extension NowPlayingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
    }
}

// MARK: -
// MARK: Setup interface methods
extension NowPlayingViewController {
    override func setupLayout() {
        self.view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(dismissButton)
        mainStackView.addArrangedSubview(coverImageView)
        mainStackView.addArrangedSubview(trackInfoHorizontalStackView)
        trackInfoHorizontalStackView.addArrangedSubview(trackInfoStackView)
        trackInfoStackView.addArrangedSubview(titleLabel)
        trackInfoStackView.addArrangedSubview(artistButton)
        
        trackInfoHorizontalStackView.addArrangedSubview(actionsButton)
        
        mainStackView.addArrangedSubview(durationSlider)
        mainStackView.addArrangedSubview(durationStackView)
        durationStackView.addArrangedSubview(currentTimeLabel)
        durationStackView.addArrangedSubview(durationSpacer)
        durationStackView.addArrangedSubview(leftTimeLabel)
        
        mainStackView.addArrangedSubview(UIView.spacer)
    }
    
    override func setupConstraints() {
        mainStackView.snp.makeConstraints { make in
            make.top.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.bottom.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
        
        dismissButton.snp.makeConstraints({ $0.height.equalTo(30) })
        coverImageView.snp.makeConstraints({ $0.height.width.equalTo(mainStackView.snp.width) })
        let trackInfoHeight = self.titleLabel.textSize.height + (self.artistButton.titleLabel?.textSize.height ?? 0) + 8
        trackInfoStackView.snp.makeConstraints({ $0.height.equalTo(trackInfoHeight) })
        titleLabel.snp.makeConstraints({ $0.height.equalTo(titleLabel.textSize.height).priority(.high) })
        actionsButton.snp.makeConstraints({ $0.height.width.equalTo(self.trackInfoStackView.snp.height) })
        durationSlider.snp.makeConstraints({ $0.height.equalTo(durationSlider.intrinsicContentSize.height) })
        durationStackView.snp.makeConstraints({ $0.height.equalTo(currentTimeLabel.textSize.height) })
        currentTimeLabel.snp.makeConstraints({ $0.width.equalTo(currentTimeLabel.textSize.width) })
        leftTimeLabel.snp.makeConstraints({ $0.width.equalTo(leftTimeLabel.textSize.width) })
    }
    
    private func setupDuration(_ duration: Float, currentTime: Float) {
        currentTimeLabel.text = currentTime.toMinuteAndSeconds
        leftTimeLabel.text = "-\((duration - currentTime).toMinuteAndSeconds)"
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
}

// MARK: -
// MARK: SliderControlDelegate
extension NowPlayingViewController: SliderControlDelegate {
    func valueBeganChange(_ value: Float) {
        AudioPlayer.shared.isDurationChanging = true
    }
    
    func valueChanging(_ value: Float) {
        guard let doubleDuration = AudioPlayer.shared.duration else { return }
        
        let duration = Float(doubleDuration)
        self.setupDuration(duration, currentTime: value * duration)
    }
    
    func valueDidChange(_ value: Float) {
        AudioPlayer.shared.isDurationChanging = false
        AudioPlayer.shared.updateTimePosition(value)
    }
    
    func valueDidNotChange() {}
}

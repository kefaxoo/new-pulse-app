//
//  NowPlayingViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 13.09.23.
//

import UIKit

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
        return button
    }()
    
    private lazy var presenter: NowPlayingPresenter = {
        let presenter = NowPlayingPresenter()
        presenter.delegate = self
        return presenter
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        self.view.addSubview(dismissButton)
        self.view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(coverImageView)
        mainStackView.addArrangedSubview(trackInfoHorizontalStackView)
        trackInfoHorizontalStackView.addArrangedSubview(trackInfoStackView)
        trackInfoStackView.addArrangedSubview(titleLabel)
        trackInfoStackView.addArrangedSubview(artistButton)
        
        trackInfoHorizontalStackView.addArrangedSubview(actionsButton)
    }
    
    override func setupConstraints() {
        dismissButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(dismissButton.snp.bottom).offset(20)
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.bottom.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
        
        coverImageView.snp.makeConstraints({ $0.height.width.equalTo(mainStackView.snp.width) })
        actionsButton.snp.makeConstraints({ $0.height.width.equalTo(50) })
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

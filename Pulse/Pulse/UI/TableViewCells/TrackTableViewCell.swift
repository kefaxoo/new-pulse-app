//
//  TrackTableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import UIKit
import PulseUIComponents

final class TrackTableViewCell: BaseUITableViewCell {
    private lazy var coverImageView: CoverImageView = {
        let imageView = CoverImageView(tintColor: SettingsManager.shared.color.color)
        imageView.layer.cornerRadius = 10
        imageView.state = .stopped
        return imageView
    }()
    
    private lazy var trackInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.text = "Title"
        return label
    }()
    
    private lazy var serviceImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.layer.cornerRadius = 6
        return imageView
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
    
    private lazy var rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var libraryImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.tintColor = SettingsManager.shared.color.color
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var actionsButton: UIButton = {
        let button = UIButton()
        button.setImage(Constants.Images.actions.image, for: .normal)
        button.tintColor = SettingsManager.shared.color.color
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private lazy var unavailableView: UIView = {
        let view = UIView(with: .label.withAlphaComponent(0.5))
        view.isHidden = true
        return view
    }()
    
    private lazy var actionsManager: ActionsManager = {
        return ActionsManager(self)
    }()
    
    private var track: TrackModel?
    
    func setupCell(_ track: TrackModel, state: CoverImageViewState, isSearchController: Bool = false, isLibraryController: Bool = false) {
        self.track = track
        self.coverImageView.setImage(from: track.image?.small)
        self.coverImageView.state = state
        
        self.titleLabel.text  = track.title
        self.artistLabel.text = track.artistText
        self.serviceImageView.isHidden = isSearchController
        self.serviceImageView.image = track.service.image
        self.explicitImageView.isHidden = true
        self.actionsButton.menu = actionsManager.trackActions(track)
        
        self.libraryImageView.image = track.libraryState.image
        self.libraryImageView.isHidden = !((track.libraryState == .added && !isLibraryController) || track.libraryState == .downloaded)
        
        self.unavailableView.isHidden = track.isAvailable
        self.setupConstraints()
    }
    
    func changeState(_ state: CoverImageViewState) {
        self.coverImageView.state = state
    }
}

// MARK: -
// MARK: Lifecycle methods
extension TrackTableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.coverImageView.reset()
        self.titleLabel.text = nil
        self.serviceImageView.image = nil
        self.artistLabel.text = nil
        self.actionsButton.menu = nil
        self.libraryImageView.image = nil
        self.libraryImageView.isHidden = true
        self.unavailableView.isHidden = true
        
        let color = SettingsManager.shared.color.color
        self.actionsButton.tintColor = color
        self.libraryImageView.tintColor = color
    }
}

// MARK: -
// MARK: Setup interface methods
extension TrackTableViewCell {
    override func setupInterface() {
        self.setupLayout()
    }
    
    override func setupLayout() {
        self.contentView.addSubview(coverImageView)
        self.contentView.addSubview(trackInfoStackView)
        trackInfoStackView.addArrangedSubview(titleLabel)
        trackInfoStackView.addArrangedSubview(explicitAndArtistStackView)
        explicitAndArtistStackView.addArrangedSubview(serviceImageView)
        explicitAndArtistStackView.addArrangedSubview(explicitImageView)
        explicitAndArtistStackView.addArrangedSubview(artistLabel)
    
        self.contentView.addSubview(rightStackView)
        rightStackView.addArrangedSubview(libraryImageView)
        rightStackView.addArrangedSubview(actionsButton)
        
        self.contentView.addSubview(unavailableView)
    }
    
    override func setupConstraints() {
        coverImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(10)
            make.height.width.equalTo(42)
        }
        
        rightStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
        
        actionsButton.snp.makeConstraints({ $0.width.equalTo(20) })
        libraryImageView.snp.makeConstraints({ $0.width.equalTo(20) })
        
        self.layoutIfNeeded()
        
        trackInfoStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().inset(12)
            make.leading.equalTo(self.coverImageView.snp.trailing).offset(12)
            make.trailing.equalTo(self.rightStackView.snp.leading).offset(-12)
        }
        
        serviceImageView.snp.makeConstraints({ $0.height.width.equalTo(self.explicitAndArtistStackView.snp.height) })
        unavailableView.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
}

// MARK: -
// MARK: ActionsManagerDelegate
extension TrackTableViewCell: ActionsManagerDelegate {
    func updatedTrack(_ track: TrackModel) {
        self.track = track
    }
    
    func updateButtonMenu() {
        guard let track else { return }
        
        actionsButton.menu = actionsManager.trackActions(track)
    }
    
    func reloadData() {
        self.delegate?.reloadData()
    }
}

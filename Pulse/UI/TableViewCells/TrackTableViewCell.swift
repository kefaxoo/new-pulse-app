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
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .light)
        label.textColor = .systemGray2
        return label
    }()
    
    private lazy var trackInfoTopStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(.newSpacer)
        return stackView
    }()
    
    private lazy var labelsImageView = [UIImageView]()
    
    private lazy var serviceImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.layer.cornerRadius = 6
        return imageView
    }()
    
    private lazy var explicitImageView = UIImageView.explicitImageView
    
    private lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(hex: "#848484")
        return label
    }()
    
    private lazy var trackInfoBottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.addArrangedSubview(serviceImageView)
        stackView.addArrangedSubview(explicitImageView)
        stackView.addArrangedSubview(artistLabel)
        return stackView
    }()
    
    private lazy var trackInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.addArrangedSubview(trackInfoTopStackView)
        stackView.addArrangedSubview(trackInfoBottomStackView)
        return stackView
    }()
    
    private lazy var libraryImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.tintColor = SettingsManager.shared.color.color
        return imageView
    }()
    
    private lazy var actionsButton: UIButton = {
        let button = UIButton()
        button.setImage(Constants.Images.actions.image, for: .normal)
        button.tintColor = SettingsManager.shared.color.color
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private lazy var rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.addArrangedSubview(libraryImageView)
        stackView.addArrangedSubview(actionsButton)
        return stackView
    }()
    
    private var track: TrackModel?
    private var isLibraryController = false
}

// MARK: -
// MARK: Lifecycle
extension TrackTableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.coverImageView.reset()
        self.coverImageView.sd_cancelCurrentImageLoad()
        
        self.titleLabel.text = nil
        self.subtitleLabel.text = nil
        
        self.labelsImageView.forEach({ $0.removeFromSuperview() })
        self.labelsImageView.removeAll()
        self.serviceImageView.image = nil
        self.artistLabel.text = nil
        self.libraryImageView.image = nil
        self.actionsButton.menu = nil
    }
}

// MARK: -
// MARK: Setup inteface methods
extension TrackTableViewCell {
    override func setupLayout() {
        self.contentView.addSubview(coverImageView)
        self.contentView.addSubview(trackInfoStackView)
        self.contentView.addSubview(rightStackView)
    }
    
    override func setupConstraints() {
        coverImageView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview().inset(UIEdgeInsets(horizontal: 20, vertical: 10))
            make.height.width.equalTo(42)
        }
        
        serviceImageView.snp.makeConstraints({ $0.width.equalTo(16) })
        
        explicitImageView.snp.makeConstraints({ $0.width.equalTo(16) })
        
        trackInfoStackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(coverImageView)
            make.leading.equalTo(coverImageView.snp.trailing).offset(12)
            make.trailing.equalTo(rightStackView.snp.leading).offset(-12)
        }
        
        libraryImageView.snp.makeConstraints({ $0.width.equalTo(25) })
        actionsButton.snp.makeConstraints({ $0.width.equalTo(25) })
        
        rightStackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(coverImageView)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
}

// MARK: -
// MARK: Public methods
extension TrackTableViewCell {
    func setupCell(_ track: TrackModel, state: CoverImageViewState, isSearchController: Bool = false, isLibraryController: Bool = false) {
        self.track = track
        self.isLibraryController = isLibraryController
        
        self.coverImageView.setImage(from: track.image?.small)
        self.coverImageView.state = state
        
        self.titleLabel.text = track.title
        self.subtitleLabel.text = track.subtitle
        
        track.labels.forEach({ labelsImageView.append(.imageView(forLabel: $0)) })
        self.labelsImageView.forEach { imageView in
            imageView.snp.makeConstraints({ $0.height.width.equalTo(16) })
            trackInfoBottomStackView.insertArrangedSubview(imageView, at: 0)
        }
        
        self.serviceImageView.image = track.service.image
        self.explicitImageView.isHidden = !track.isExplicit
        
        self.artistLabel.text = track.artistText
        
        track.libraryState { [weak self] state in
            DispatchQueue.main.async {
                self?.libraryImageView.setImage(state.image)
                self?.libraryImageView.isHidden = !((state == .added && !isLibraryController) || state == .downloaded)
            }
        }
        
        ActionsManager(nil).trackActions(for: track) { [weak self] menu in
            DispatchQueue.main.async {
                self?.actionsButton.menu = menu
            }
        }
    }
    
    func changeState(_ state: CoverImageViewState) {
        self.coverImageView.state = state
    }
    
    func changeColor() {
        self.coverImageView.tintColor = SettingsManager.shared.color.color
        self.explicitImageView.tintColor = SettingsManager.shared.color.color
        self.libraryImageView.tintColor = SettingsManager.shared.color.color
        self.actionsButton.tintColor = SettingsManager.shared.color.color
    }
}

// MARK: -
// MARK: ActionsManagerDelegate
extension TrackTableViewCell: ActionsManagerDelegate {
    func updateButtonMenu() {
        guard let track else { return }
        
        ActionsManager(nil).trackActions(for: track) { [weak self] menu in
            DispatchQueue.main.async {
                self?.actionsButton.menu = menu
            }
        }
    }
    
    func updateTrackState(_ state: TrackLibraryState) {
        self.libraryImageView.image = state.image
        self.libraryImageView.isHidden = !((state == .added && !self.isLibraryController) || state == .downloaded)
    }
}

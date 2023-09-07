//
//  TrackTableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import UIKit

final class TrackTableViewCell: BaseUITableViewCell {
    private lazy var coverImageView: CoverImageView = {
        let imageView = CoverImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private lazy var trackInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var headerSpacer = UIView.spacer
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.text = "Title"
        return label
    }()
    
    private lazy var serviceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
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
    
    private lazy var footerSpacer = UIView.spacer
    
    private lazy var actionsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: Constants.Images.System.ellipsis), for: .normal)
        button.tintColor = SettingsManager.shared.color.color
        return button
    }()
    
    func setupCell(_ track: TrackModel, isSearchController: Bool = false) {
        self.coverImageView.setImage(from: track.image.small)
        self.titleLabel.text  = track.title
        self.artistLabel.text = track.artistText
        self.serviceImageView.isHidden = isSearchController
        self.serviceImageView.image = track.service.image
        self.explicitImageView.isHidden = true
    }
}

// MARK: -
// MARK: Setup interface methods
extension TrackTableViewCell {
    override func setupLayout() {
        self.contentView.addSubview(coverImageView)
        self.contentView.addSubview(trackInfoStackView)
        trackInfoStackView.addArrangedSubview(headerSpacer)
        trackInfoStackView.addArrangedSubview(titleLabel)
        trackInfoStackView.addArrangedSubview(explicitAndArtistStackView)
        explicitAndArtistStackView.addArrangedSubview(serviceImageView)
        explicitAndArtistStackView.addArrangedSubview(explicitImageView)
        explicitAndArtistStackView.addArrangedSubview(artistLabel)
        
        trackInfoStackView.addArrangedSubview(footerSpacer)
        
        self.contentView.addSubview(actionsButton)
    }
    
    override func setupConstraints() {
        coverImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
            make.height.width.equalTo(42)
        }
        
        actionsButton.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.width.equalTo(self.contentView.snp.height)
        }
        
        trackInfoStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(coverImageView.snp.trailing).offset(12)
            make.trailing.equalTo(actionsButton.snp.leading).inset(12)
        }
        
        headerSpacer.snp.makeConstraints({ $0.width.equalTo(1) })
        footerSpacer.snp.makeConstraints({ $0.width.equalTo(1) })
    }
}

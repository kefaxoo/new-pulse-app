//
//  PlaylistTableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 19.09.23.
//

import UIKit

final class PlaylistTableViewCell: BaseUITableViewCell {
    private lazy var playlistImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private lazy var playlistTitleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.image = Constants.Images.chevronRight.image
        imageView.tintColor = .label.withAlphaComponent(0.7)
        return imageView
    }()
    
    private var playlist: PlaylistModel?
    
    func setupCell(_ playlist: PlaylistModel) {
        self.playlist = playlist
        
        self.playlistTitleLabel.text = playlist.title
    }
}

// MARK: -
// MARK: Lifecycle methods
extension PlaylistTableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.playlistTitleLabel.text = ""
    }
}

// MARK: -
// MARK: Setup interface methods
extension PlaylistTableViewCell {
    override func setupLayout() {
        self.contentView.addSubview(playlistImageView)
        self.contentView.addSubview(playlistTitleLabel)
        self.contentView.addSubview(chevronImageView)
    }
    
    override func setupConstraints() {
        playlistImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
            make.height.width.equalTo(50)
        }
        
        playlistTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(playlistImageView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }
        
        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.equalTo(playlistTitleLabel.snp.trailing).offset(10)
            make.width.equalTo(20)
        }
    }
}

//
//  PlaylistCollectionViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 15.01.24.
//

import UIKit
import PulseUIComponents

final class PlaylistCollectionViewCell: BaseUICollectionViewCell {
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.addArrangedSubview(coverImageView)
        stackView.addArrangedSubview(titleLabel)
        return stackView
    }()
    
    func configure(withPlaylist playlist: PlaylistModel) {
        self.coverImageView.setImage(from: playlist.image?.original)
        self.titleLabel.text = playlist.title
    }
    
    class func height(withPlaylist playlist: PulsePlaylist) -> CGFloat {
        var height: CGFloat = 200 + 6
        height += playlist.title.height(withWidth: 200, font: .systemFont(ofSize: 15))
        return height
    }
}

// MARK: -
// MARK: Setup interface methods
extension PlaylistCollectionViewCell {
    override func setupLayout() {
        self.addSubview(contentStackView)
    }
    
    override func setupConstraints() {
        contentStackView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        
        coverImageView.snp.makeConstraints({ $0.height.width.equalTo(200) })
    }
}

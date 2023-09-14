//
//  ScrollingCoverCollectionViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit
import SDWebImage

class ScrollingCoverCollectionViewCell: BaseUICollectionViewCell {
    private lazy var mainView = UIView(with: .clear)
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    func setupImage(link: String) {
        self.coverImageView.setImage(from: link)
    }
}

// MARK: -
// MARK: Setup interface methods
extension ScrollingCoverCollectionViewCell {
    override func setupLayout() {
        self.addSubview(mainView)
        mainView.addSubview(coverImageView)
    }
    
    override func setupConstraints() {
        mainView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        coverImageView.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
}

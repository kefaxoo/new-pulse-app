//
//  ScrollingCoverCollectionViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit
import SDWebImage

class ScrollingCoverCollectionViewCell: UICollectionViewCell {
    private lazy var mainView: UIView = UIView(with: .clear)
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupInterface()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupInterface()
    }
    
    private func setupInterface() {
        setupLayout()
        setupConstraints()
    }
    
    private func setupLayout() {
        self.addSubview(mainView)
        mainView.addSubview(coverImageView)
    }
    
    private func setupConstraints() {
        mainView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        coverImageView.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
    
    func setupImage(link: String) {
        coverImageView.setImage(from: link)
    }
}

//
//  VKAuthTableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 5.09.23.
//

import UIKit

final class VKAuthTableViewCell: ChevronTableViewCell {
    private lazy var vkLogoImageView: UIImageView = {
        let imageView = UIImageView.defaultImageView
        imageView.image = UIImage(named: Constants.Images.Custom.vkMusicLogo)
        imageView.layer.cornerRadius = 6
        return imageView
    }()
    
    override func setupLayout() {
        super.setupLayout()
        mainStackView.insertArrangedSubview(vkLogoImageView, at: 0)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        vkLogoImageView.snp.makeConstraints({ $0.width.height.equalTo(25) })
    }
}

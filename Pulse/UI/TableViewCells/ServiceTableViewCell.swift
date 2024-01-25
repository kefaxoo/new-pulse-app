//
//  ServiceTableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.12.23.
//

import UIKit
import PulseUIComponents

final class ServiceTableViewCell: BaseUITableViewCell {
    private lazy var serviceImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        return imageView
    }()
    
    private lazy var serviceLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var chevronImageView = UIImageView.chevronRightImageView
    
    func configure(withLink link: OdesliLink) {
        self.serviceImageView.image = link.type.image
        self.serviceLabel.text = link.type.title
    }
}

// MARK: -
// MARK: Setup interface methods
extension ServiceTableViewCell {
    override func setupLayout() {
        self.contentView.addSubview(serviceImageView)
        self.contentView.addSubview(serviceLabel)
        self.contentView.addSubview(chevronImageView)
    }
    
    override func setupConstraints() {
        serviceImageView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview().inset(UIEdgeInsets(horizontal: 20, vertical: 10))
            make.height.width.equalTo(30)
        }
        
        serviceLabel.snp.makeConstraints { make in
            make.leading.equalTo(serviceImageView.snp.trailing).offset(16)
            make.centerY.equalTo(serviceImageView.snp.centerY)
        }
        
        chevronImageView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(UIEdgeInsets(horizontal: 20, vertical: 10))
            make.height.width.equalTo(30)
        }
    }
}

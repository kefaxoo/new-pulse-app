//
//  ChevronTableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 5.09.23.
//

import UIKit

class ChevronTableViewCell: BaseUITableViewCell {
    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        label.textColor = .label.withAlphaComponent(0.7)
        return label
    }()
    
    private lazy var chevronImageView = UIImageView.chevronRightImageView
    
    override func setupLayout() {
        self.contentView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(contentStackView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        
        mainStackView.addArrangedSubview(chevronImageView)
    }
    
    override func setupConstraints() {
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(10)
        }
        
        chevronImageView.snp.makeConstraints { make in
            make.width.equalTo(25)
        }
    }
    
    func setupCell(type: SettingType) {
        self.selectionStyle = type.selectionStyle
        titleLabel.text = type.title
        if let description = type.description {
            descriptionLabel.text = description
        } else {
            descriptionLabel.isHidden = true
        }
    }
}


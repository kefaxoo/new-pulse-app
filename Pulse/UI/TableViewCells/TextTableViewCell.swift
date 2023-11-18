//
//  TextTableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 5.09.23.
//

import UIKit

class TextTableViewCell: BaseUITableViewCell {
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
    
    override func setupLayout() {
        self.contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
    }
    
    override func setupConstraints() {
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(10)
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

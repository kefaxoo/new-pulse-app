//
//  LibraryTableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 10.09.23.
//

import UIKit

final class LibraryTableViewCell: BaseUITableViewCell {
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.tintColor = SettingsManager.shared.color.color
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var spacer           = UIView.spacer
    private lazy var chevronImageView = UIImageView.chevronRightImageView
    
    func setupCell(_ type: LibraryType) {
        self.iconImageView.image = type.image
        self.titleLabel.text = type.title
    }
}

// MARK: -
// MARK: Lifecycle
extension LibraryTableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        self.iconImageView.tintColor = SettingsManager.shared.color.color
    }
}

// MARK: -
// MARK: Setup interface methods
extension LibraryTableViewCell {
    override func setupLayout() {
        self.contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(spacer)
        contentStackView.addArrangedSubview(chevronImageView)
    }
    
    override func setupConstraints() {
        self.contentStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(10)
            make.height.equalTo(25)
        }
        
        iconImageView.snp.makeConstraints({ $0.width.equalTo(self.contentStackView.snp.height) })
        chevronImageView.snp.makeConstraints({ $0.width.equalTo(self.contentStackView.snp.height) })
        spacer.snp.makeConstraints({ $0.height.equalTo(1) })
        titleLabel.snp.makeConstraints({ $0.centerY.equalToSuperview() })
    }
    
    func changeColor() {
        self.iconImageView.tintColor = SettingsManager.shared.color.color
    }
}

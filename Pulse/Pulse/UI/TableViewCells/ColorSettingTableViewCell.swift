//
//  ColorSettingTableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import UIKit

final class ColorSettingTableViewCell: BaseUITableViewCell {
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
    
    private lazy var colorChangeButton: UIButton = {
        let button = UIButton()
        button.setTitle(SettingsManager.shared.color.title, for: .normal)
        button.tintColor = SettingsManager.shared.color.color
        button.configuration = UIButton.Configuration.tinted()
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    func setupCell(type: SettingType) {
        self.selectionStyle = type.selectionStyle
        self.titleLabel.text = type.title
        self.descriptionLabel.text = type.description
    }
}

// MARK: -
// MARK: Lifecycle
extension ColorSettingTableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        
        let color = SettingsManager.shared.color
        self.colorChangeButton.menu = nil
        self.colorChangeButton.tintColor = color.color
        self.colorChangeButton.setTitle(color.title, for: .normal)
        
        self.setupColorButton()
    }
}

// MARK: -
// MARK: Setup interface methods
extension ColorSettingTableViewCell {
    override func setupInterface() {
        super.setupInterface()
        self.setupColorButton()
    }
    
    override func setupLayout() {
        self.contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        
        self.contentView.addSubview(colorChangeButton)
    }
    
    override func setupConstraints() {
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(10)
        }
        
        colorChangeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.leading.equalTo(self.contentStackView.snp.trailing).offset(16)
            make.centerY.equalTo(self.contentStackView.snp.centerY)
        }
        
        self.layoutIfNeeded()
    }
    
    private func setupColorButton() {
        var actions = [UIAction]()
        ColorType.allCases.forEach { color in
            let action = UIAction(title: color.title, state: color.isEqual(to: SettingsManager.shared.color)) { [weak self] _ in
                SettingsManager.shared.color = color
                self?.delegate?.reloadData()
            }
            
            actions.append(action)
        }
        
        self.colorChangeButton.menu = UIMenu(options: .displayInline, children: actions)
    }
}

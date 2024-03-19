//
//  SwitchTableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 4.09.23.
//

import UIKit

class SwitchTableViewCell: BaseUITableViewCell {
    private lazy var mainStackView: UIStackView = {
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
    
    private lazy var `switch`: UISwitch = {
        let `switch` = UISwitch()
        `switch`.addTarget(self, action: #selector(switchStateChanged), for: .valueChanged)
        `switch`.onTintColor = SettingsManager.shared.color.color
        return `switch`
    }()
    
    private var closure: ((Bool) -> ())?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.switch.onTintColor = SettingsManager.shared.color.color
    }
    
    override func setupLayout() {
        self.contentView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(contentStackView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        
        mainStackView.addArrangedSubview(`switch`)
    }
    
    override func setupConstraints() {
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(10)
        }
        
        `switch`.snp.makeConstraints({ $0.centerY.equalTo(contentStackView.snp.centerY) })
    }
    
    func setupCell(type: SettingType, closure: @escaping((Bool) -> ())) {
        self.selectionStyle = type.selectionStyle
        titleLabel.text = type.title
        if let description = type.description {
            descriptionLabel.text = description
        } else {
            descriptionLabel.isHidden = true
        }
        
        if let state = type.state {
            `switch`.isOn = state
        } else {
            `switch`.isEnabled = false
        }
        
        self.closure = closure
    }
    
    @objc private func switchStateChanged(_ sender: UISwitch) {
        self.closure?(sender.isOn)
    }
}

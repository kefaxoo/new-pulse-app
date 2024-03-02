//
//  TextFieldButtonTableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 2.03.24.
//

import UIKit
import PulseUIComponents

final class TextFieldButtonTableViewCell: BaseUITableViewCell {
    typealias TextFieldButtonCompletion = ((Any?) -> ())
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.tintColor = SettingsManager.shared.color.color
        return textField
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.tintColor = SettingsManager.shared.color.color
        button.configuration = .tinted()
        button.addTarget(self, action: #selector(actionButtonDidTap), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(actionButton)
        return stackView
    }()
    
    private var type: SettingType?
    
    func setupCell(type: SettingType) {
        self.type = type
        self.selectionStyle = type.selectionStyle
        self.titleLabel.text = type.title
        self.textField.placeholder = type.textFieldPlaceholder
        self.textField.text = type.textFieldText
        self.actionButton.isHidden = type.buttonName.isEmpty
        self.actionButton.setTitle(type.buttonName, for: .normal)
    }
}

// MARK: -
// MARK: Setup interface methods
extension TextFieldButtonTableViewCell {
    override func setupLayout() {
        self.contentView.addSubview(verticalStackView)
    }
    
    override func setupConstraints() {
        verticalStackView.snp.makeConstraints({ $0.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: 20, vertical: 10)) })
    }
}

// MARK: -
// MARK: Actions
extension TextFieldButtonTableViewCell {
    @objc func actionButtonDidTap(_ sender: UIButton) {
        guard let text = textField.text else { return }
        
        switch type {
            case .yandexMusicToken:
                if SettingsManager.shared.yandexMusic.isSigned {
                    SettingsManager.shared.yandexMusic.updateToken(text)
                } else {
                    SettingsManager.shared.yandexMusic.saveToken(text)
                }
                
                self.delegate?.reloadData()
            default:
                break
        }
    }
}

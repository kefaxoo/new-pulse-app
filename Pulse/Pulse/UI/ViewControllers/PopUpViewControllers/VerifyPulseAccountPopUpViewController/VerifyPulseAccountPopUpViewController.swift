//
//  VerifyPulseAccountPopUpViewController.swift
//  Pulse
//
//  Created by ios on 31.08.23.
//

import UIKit

final class VerifyPulseAccountPopUpViewController: PopUpViewController {
    private lazy var verificationCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.text = self.presenter?.verificationCodeAsString
        label.textAlignment = .center
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel(text: self.presenter?.descriptionText)
        label.textColor = .label.withAlphaComponent(0.7)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var openTelegramBotButton: UIButton = {
        let button = UIButton()
        button.configuration = UIButton.Configuration.filled()
        button.tintColor = SettingsManager.shared.color.color
        button.setTitle("Open Telegram Bot", for: .normal)
        button.addTarget(self, action: #selector(openTelegramBotAction), for: .touchUpInside)
        return button
    }()
    
    private var presenter: VerifyPulseAccountPresenter?
    
    init(verificationCode: VerificationCode) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.presenter = VerifyPulseAccountPresenter(verificationCode: verificationCode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// MARK: Setup interface methods
extension VerifyPulseAccountPopUpViewController {
    override func setupInterface() {
        super.setupInterface()
        self.titleLabel.text = "Verification Code"
    }
    
    override func setupLayout() {
        super.setupLayout()
        mainStackView.addArrangedSubview(verificationCodeLabel)
        mainStackView.addArrangedSubview(descriptionLabel)
        mainStackView.addArrangedSubview(openTelegramBotButton)
    }
}

// MARK: -
// MARK: Actions
extension VerifyPulseAccountPopUpViewController {
    @objc private func openTelegramBotAction(_ sender: UIButton) {
        self.presenter?.openTelegramBot()
    }
}

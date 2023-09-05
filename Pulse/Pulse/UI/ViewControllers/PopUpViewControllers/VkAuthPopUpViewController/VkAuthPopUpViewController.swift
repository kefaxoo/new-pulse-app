//
//  VkAuthPopUpViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 5.09.23.
//

import UIKit

final class VkAuthPopUpViewController: PopUpViewController {
    private lazy var usernameTextField: UITextField = {
        let textField = UITextField(withPlaceholder: "Username")
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private lazy var passwordTextField = PasswordTextField()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton()
        button.configuration = UIButton.Configuration.filled()
        button.tintColor = SettingsManager.shared.color.color
        button.setTitle("Sign in", for: .normal)
        button.addTarget(self, action: #selector(signInAction), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// MARK: Setup interface methods
extension VkAuthPopUpViewController {
    override func setupInterface() {
        super.setupInterface()
        self.titleLabel.text = "VK Auth"
    }
    
    override func setupLayout() {
        super.setupLayout()
        mainStackView.addArrangedSubview(usernameTextField)
        mainStackView.addArrangedSubview(passwordTextField)
        mainStackView.addArrangedSubview(signInButton)
    }
}

// MARK: -
// MARK: Actions
extension VkAuthPopUpViewController {
    @objc private func signInAction(_ sender: UIButton) {
        
    }
}

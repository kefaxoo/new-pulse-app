//
//  AuthViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit
import SnapKit

final class AuthViewController: BaseUIViewController {
    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 26
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(text: "Pulse")
        label.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton()
        button.configuration = UIButton.Configuration.filled()
        button.setTitle("Sign in", for: .normal)
        button.tintColor = SettingsManager.shared.color.color
        return button
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.configuration = UIButton.Configuration.filled()
        button.setTitle("Sign up", for: .normal)
        button.tintColor = SettingsManager.shared.color.color
        return button
    }()
    
    private lazy var continueWithAppleButton: UIButton = {
        let button = UIButton()
        button.configuration = UIButton.Configuration.filled()
        button.setTitle("Continue with Apple", for: .normal)
        button.tintColor = .black
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private lazy var continueWithGoogleButton: UIButton = {
        let button = UIButton()
        button.configuration = UIButton.Configuration.filled()
        button.setTitle("Continue with Google", for: .normal)
        button.tintColor = UIColor(hex: "#DC342A") ?? .systemRed
        return button
    }()
}

// MARK: -
// MARK: Setup interface methods
extension AuthViewController {
    override func setupLayout() {
        self.view.addSubview(bottomStackView)
        bottomStackView.addArrangedSubview(titleLabel)
        bottomStackView.addArrangedSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(signInButton)
        buttonsStackView.addArrangedSubview(signUpButton)
        buttonsStackView.addArrangedSubview(continueWithAppleButton)
        buttonsStackView.addArrangedSubview(continueWithGoogleButton)
    }
    
    override func setupConstraints() {
        bottomStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(30)
        }
    }
}

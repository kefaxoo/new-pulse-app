//
//  AuthViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit
import SnapKit

final class AuthViewController: CoversViewController {
    private lazy var bottomGradientView: StaticGradientView = {
        let staticGradientView = StaticGradientView()
        staticGradientView.updateGradient(startColor: .systemBackground.withAlphaComponent(0), endColor: .systemBackground, startLocation: 0, endLocation: 0.33)
        return staticGradientView
    }()
    
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
        button.tag = 1001
        button.addTarget(self, action: #selector(authAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.configuration = UIButton.Configuration.tinted()
        button.setTitle("Sign up", for: .normal)
        button.tintColor = SettingsManager.shared.color.color
        button.tag = 1002
        button.addTarget(self, action: #selector(authAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var continueWithAppleButton: UIButton = {
        let button = UIButton()
        var configuartion = UIButton.Configuration.filled()
        configuartion.image = UIImage(systemName: Constants.Images.System.appleLogo)
        configuartion.imagePlacement = .leading
        configuartion.imagePadding = 8
        button.configuration = configuartion
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
    
    private lazy var presenter: AuthPresenter = {
        let presenter = AuthPresenter()
        presenter.delegate = self
        return presenter
    }()
}

// MARK: -
// MARK: Setup interface methods
extension AuthViewController {
    override func setupLayout() {
        super.setupLayout()
        self.view.addSubview(bottomGradientView)
        self.view.addSubview(bottomStackView)
        bottomStackView.addArrangedSubview(titleLabel)
        bottomStackView.addArrangedSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(signInButton)
        buttonsStackView.addArrangedSubview(signUpButton)
        buttonsStackView.addArrangedSubview(continueWithAppleButton)
        buttonsStackView.addArrangedSubview(continueWithGoogleButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        bottomGradientView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(secondCoversLine.snp.top).offset(75)
        }
        
        bottomStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(30)
        }
    }
}

// MARK: -
// MARK: Actions
extension AuthViewController {
    @objc private func authAction(_ sender: UIButton) {
        switch sender.tag {
            case 1001:
                self.presenter.pushSignInVC()
            case 1002:
                self.presenter.pushSignUpVC()
            default:
                break
        }
    }
}

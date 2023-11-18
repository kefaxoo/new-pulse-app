//
//  SignUpViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import UIKit
import PulseUIComponents

final class SignUpViewController: CoversViewController {
    private lazy var bottomGradientView: StaticGradientView = {
        let staticGradientView = StaticGradientView()
        staticGradientView.updateGradient(
            startColor: .systemBackground.withAlphaComponent(0),
            endColor: .systemBackground,
            startLocation: 0,
            endLocation: 0.33
        )
        
        return staticGradientView
    }()
    
    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .equalSpacing
        stackView.contentMode = .center
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(text: "Pulse")
        label.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField(withPlaceholder: Localization.Words.email.localization)
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.tintColor = SettingsManager.shared.color.color
        return textField
    }()
    
    private lazy var passwordTextField = PasswordTextField(
        tintColor: SettingsManager.shared.color.color,
        placeholder: Localization.Words.password.localization
    )
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.configuration = UIButton.Configuration.tinted()
        button.setTitle(Localization.Words.signUp.localization, for: .normal)
        button.tintColor = SettingsManager.shared.color.color
        button.addTarget(self, action: #selector(signUpAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var presenter: SignUpPresenter = {
        let presenter = SignUpPresenter()
        presenter.delegate = self
        return presenter
    }()
    
    init(covers: [PulseCover]) {
        super.init(nibName: nil, bundle: nil)
        guard covers.count > 30 else { return }
        
        self.presenter.covers = covers
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
// MARK: Life cycle
extension SignUpViewController {
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeKeyboardObservers()
    }
}

// MARK: -
// MARK: Setup interface methods
extension SignUpViewController {
    override func setupInterface() {
        super.setupInterface()
        self.observeKeyboard(view: bottomStackView, defaultOffset: 30)
    }
    
    override func setupLayout() {
        super.setupLayout()
        self.view.addSubview(bottomGradientView)
        self.view.addSubview(bottomStackView)
        bottomStackView.addArrangedSubview(titleLabel)
        bottomStackView.addArrangedSubview(emailTextField)
        bottomStackView.addArrangedSubview(passwordTextField)
        bottomStackView.addArrangedSubview(signUpButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        bottomGradientView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(100)
        }
        
        bottomStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(30)
            make.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(30)
        }
    }
}

// MARK: -
// MARK: Delegate methods
extension SignUpViewController: SignUpPresenterDelegate {}

// MARK: -
// MARK: Actions
extension SignUpViewController {
    @objc private func signUpAction() {
        self.dismissKeyboard()
        self.presenter.createUser(email: emailTextField.text, password: passwordTextField.text)
    }
}

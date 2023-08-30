//
//  AuthViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit
import SnapKit

final class AuthViewController: BaseUIViewController {
    private lazy var firstCoversLine = CoversScrollingView()
    private lazy var secondCoversLine = CoversScrollingView()
    private lazy var thirdCoversLine = CoversScrollingView()
    private lazy var coversLines: [CoversScrollingView] = {
        return [firstCoversLine, secondCoversLine, thirdCoversLine]
    }()
    
    private lazy var bottomGradientView: StaticGradientView = {
        let staticGradientView = StaticGradientView()
        staticGradientView.updateGradient(startColor: .clear, endColor: .systemBackground, startLocation: 0, endLocation: 0.4)
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
    
    private lazy var provider: AuthProvider = {
        let provider = AuthProvider()
        provider.delegate = self
        return provider
    }()
    
    private var covers = [PulseCover]()
    private var type: AuthScreenType = .none
    
    func setupController(authScreen type: AuthScreenType, covers: [PulseCover]) {
        self.covers = covers
        self.type = type
    }
}

// MARK: -
// MARK: Life cycle
extension AuthViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.coversLines.forEach({ $0.setupTimer() })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.coversLines.forEach({ $0.removeTimer() })
    }
}

// MARK: -
// MARK: Setup interface methods
extension AuthViewController {
    override func setupInterface() {
        super.setupInterface()
        self.setupCovers(covers: covers)
    }
    
    override func setupLayout() {
        self.view.addSubview(firstCoversLine)
        self.view.addSubview(secondCoversLine)
        self.view.addSubview(thirdCoversLine)
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
        firstCoversLine.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
        }
        
        secondCoversLine.snp.makeConstraints { make in
            make.top.equalTo(firstCoversLine.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
        }
        
        thirdCoversLine.snp.makeConstraints { make in
            make.top.equalTo(secondCoversLine.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
        }
        
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
        guard let authScreenType = AuthScreenType(rawValue: sender.tag) else { return }
        
        MainCoordinator.shared.pushAuthViewController(authScreen: authScreenType, covers: covers)
    }
}

// MARK: -
// MARK: Provider methods
extension AuthViewController: AuthProviderDelegate {
    func setupCovers(covers: [PulseCover]) {
        guard self.covers.isEmpty,
              covers.count >= 30
        else { return }
        
        self.covers = covers
        self.firstCoversLine.setupCovers(covers: Array(covers[0..<10]))
        self.secondCoversLine.setupCovers(covers: Array(covers[10..<20]), start: 1)
        self.thirdCoversLine.setupCovers(covers: Array(covers[20..<30]), start: 2)
    }
}

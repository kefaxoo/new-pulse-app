//
//  ServiceSignTableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import UIKit

class ServiceSignTableViewCell: BaseUITableViewCell {
    private lazy var serviceImageView: UIImageView = {
        let imageView = UIImageView.default
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private lazy var serviceTitleLabel = UILabel()
    
    private lazy var signButton: UIButton = {
        let button = UIButton()
        button.tintColor = SettingsManager.shared.color.color
        button.configuration = UIButton.Configuration.tinted()
        button.addTarget(self, action: #selector(signAction), for: .touchUpInside)
        return button
    }()
    
    private var webViewType: WebViewType = .none
    private var type: SettingType = .none
    
    func setupCell(type: SettingType) {
        if SettingsManager.shared.soundcloud.accessToken != nil {
            SoundcloudProvider.shared.userInfo { [weak self] userInfo in
                self?.serviceImageView.setImage(from: userInfo.avatarLink)
            }
        } else {
            self.serviceImageView.image = type.service.image
        }
        
        self.serviceTitleLabel.text = type.title
        self.webViewType = type.service.webType
        self.type = type
        self.setupSignButton()
    }
}

// MARK: -
// MARK: Lifecycle
extension ServiceSignTableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.signButton.tintColor = SettingsManager.shared.color.color
        self.serviceTitleLabel.text = self.type.title
        self.setupSignButton()
    }
}

// MARK: -
// MARK: Setup interface methods
extension ServiceSignTableViewCell {
    override func setupInterface() {
        super.setupInterface()
        self.setupSignButton()
    }
    
    override func setupLayout() {
        self.contentView.addSubview(serviceImageView)
        self.contentView.addSubview(serviceTitleLabel)
        self.contentView.addSubview(signButton)
    }
    
    override func setupConstraints() {
        serviceImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(10)
            make.height.width.equalTo(30)
        }
        
        serviceTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(serviceImageView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }
        
        signButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupSignButton() {
        switch self.type.service {
            case .soundcloud:
                if SettingsManager.shared.soundcloud.accessToken != nil {
                    self.signButton.showsMenuAsPrimaryAction = true
                    self.signButton.setTitle("Menu", for: .normal)
                    let refreshAction = UIAction(title: "Refresh token") { _ in
                        guard SettingsManager.shared.soundcloud.refreshToken != nil else { return }
                        
                        MainCoordinator.shared.currentViewController?.presentSpinner()
                        SoundcloudProvider.shared.refreshToken { tokens in
                            MainCoordinator.shared.currentViewController?.dismissSpinner()
                            SettingsManager.shared.soundcloud.updateTokens(tokens)
                            
                            AlertView.shared.present(title: "Success refresh soundcloud token", alertType: .done, system: .iOS16AppleMusic)
                            
                            self.delegate?.reloadData()
                        } failure: { error in
                            MainCoordinator.shared.currentViewController?.dismissSpinner()
                            AlertView.shared.presentError(error: error?.message ?? "Unknown Soundcloud Error", system: .iOS16AppleMusic)
                        }
                    }
                    
                    let signOutAction = UIAction(title: "Sign out") { [weak self] _ in
                        guard SettingsManager.shared.soundcloud.signOut() else { return }
                        
                        self?.delegate?.reloadData()
                    }
                    
                    self.signButton.menu = UIMenu(options: .displayInline, children: [refreshAction, signOutAction])
                } else {
                    self.signButton.menu = nil
                    self.signButton.showsMenuAsPrimaryAction = false
                    self.signButton.setTitle("Sign in", for: .normal)
                }
            default:
                return
        }
    }
}

// MARK: -
// MARK: Actions
fileprivate extension ServiceSignTableViewCell {
    @objc func signAction(_ sender: UIButton) {
        if SettingsManager.shared.soundcloud.accessToken == nil {
            MainCoordinator.shared.presentWebViewController(type: self.webViewType, delegate: self)
        }
    }
}

// MARK: -
// MARK: WebViewControllerDelegate
extension ServiceSignTableViewCell: WebViewControllerDelegate {
    func viewDidDisappear() {
        MainCoordinator.shared.currentViewController?.presentSpinner()
        SoundcloudProvider.shared.signIn { [weak self] tokens in
            SoundcloudProvider.shared.userInfo(accessToken: tokens.accessToken) { [weak self] userInfo in
                MainCoordinator.shared.currentViewController?.dismissSpinner()
                SettingsManager.shared.soundcloud.updateUserInfo(userInfo)
                SettingsManager.shared.soundcloud.saveTokens(tokens)
                
                AlertView.shared.present(title: "Success sign in Soundcloud", alertType: .done, system: .iOS16AppleMusic)
                
                self?.delegate?.reloadData()
            } failure: { error in
                MainCoordinator.shared.currentViewController?.dismissSpinner()
                AlertView.shared.presentError(error: error?.message ?? "Unknown Soundcloud Error", system: .iOS16AppleMusic)
            }
        } failure: { error in
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            AlertView.shared.presentError(error: error?.message ?? "Unknown Soundcloud Error", system: .iOS16AppleMusic)
        }
    }
}

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
    
    private lazy var yandexPlusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setImage(.yandexPlusLogo)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var serviceTitleLabel = UILabel()
    
    private lazy var serviceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.addArrangedSubview(yandexPlusImageView)
        stackView.addArrangedSubview(serviceTitleLabel)
        stackView.addArrangedSubview(.spacer)
        return stackView
    }()
    
    private lazy var signButton: UIButton = {
        let button = UIButton()
        button.tintColor = SettingsManager.shared.color.color
        button.configuration = UIButton.Configuration.tinted()
        button.addTarget(self, action: #selector(signAction), for: .touchUpInside)
        return button
    }()
    
    private var webViewType: WebViewType = .none
    private var type: SettingType = .none
    private var section: Int = 0
    private var screenId: URL?
    
    func setupCell(type: SettingType, section: Int, screenId: URL? = nil) {
        self.section = section
        self.serviceImageView.image = type.service.image
        self.screenId = screenId
        switch type.service {
            case .soundcloud:
                guard SettingsManager.shared.soundcloud.isSigned else { break }
                
                SoundcloudProvider.shared.userInfo(success: { self.serviceImageView.setImage(from: $0.avatarLink) })
            case .yandexMusic:
                guard SettingsManager.shared.yandexMusic.isSigned else { break }
                
                YandexMusicProvider.shared.fetchUserProfileInfo(success: { self.serviceImageView.setImage(from: $0.avatarLink) })
                YandexMusicProvider.shared.fetchAccountInfo { [weak self] status in
                    SettingsManager.shared.yandexMusic.hasPlus = status.plus.hasPlus
                    self?.yandexPlusImageView.smoothIsHidden = !status.plus.hasPlus
                    self?.setupConstraints()
                }
            default:
                break
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
        self.yandexPlusImageView.isHidden = true
        self.setupSignButton()
    }
}

// MARK: -
// MARK: Setup interface methods
extension ServiceSignTableViewCell {
    override func setupInterface() {
        super.setupInterface()
        self.setupSignButton()
        self.selectionStyle = self.type.selectionStyle
    }
    
    override func setupLayout() {
        self.contentView.addSubview(serviceImageView)
        self.contentView.addSubview(serviceTitleLabel)
        self.contentView.addSubview(yandexPlusImageView)
        self.contentView.addSubview(signButton)
    }
    
    override func setupConstraints() {
        serviceImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(10)
            make.height.width.equalTo(30)
        }
        
        serviceTitleLabel.snp.remakeConstraints { make in
            make.leading.equalTo(serviceImageView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            guard yandexPlusImageView.isHidden else { return }
            
            make.trailing.equalTo(signButton.snp.leading).offset(-10)
        }
        
        yandexPlusImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(441 * 20 / 185)
            make.leading.equalTo(serviceTitleLabel.snp.trailing).offset(10)
            make.trailing.equalTo(signButton.snp.leading).offset(-10)
        }
        
        signButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupSignButton() {
        self.signButton.menu = nil
        self.signButton.showsMenuAsPrimaryAction = false
        self.signButton.setTitle(Localization.Words.signIn.localization, for: .normal)
        
        switch self.type.service {
            case .soundcloud:
                guard SettingsManager.shared.soundcloud.isSigned else { return }
                
                self.signButton.showsMenuAsPrimaryAction = true
                self.signButton.setTitle(Localization.Words.menu.localization, for: .normal)
                let refreshAction = UIAction(title: Localization.Lines.refreshToken.localization) { _ in
                    guard SettingsManager.shared.soundcloud.refreshToken != nil else { return }
                    
                    MainCoordinator.shared.currentViewController?.presentSpinner()
                    SoundcloudProvider.shared.refreshToken { tokens in
                        MainCoordinator.shared.currentViewController?.dismissSpinner()
                        SettingsManager.shared.soundcloud.updateTokens(tokens)
                        
                        AlertView.shared.present(
                            title: Localization.Lines.successRefreshToken.localization(with: "Soundcloud"),
                            alertType: .done,
                            system: .iOS16AppleMusic
                        )
                        
                        self.delegate?.reloadCells(at: self.section)
                    } failure: { error in
                        MainCoordinator.shared.currentViewController?.dismissSpinner()
                        AlertView.shared.presentError(
                            error: error?.message ?? Localization.Lines.unknownError.localization(with: "Soundcloud"),
                            system: .iOS16AppleMusic
                        )
                    }
                }
                
                let signOutAction = UIAction(title: Localization.Words.signOut.localization) { [weak self] _ in
                    guard SettingsManager.shared.soundcloud.signOut(),
                          let self
                    else { return }
                    
                    self.delegate?.reloadCells(at: self.section)
                }
                
                self.signButton.menu = UIMenu(options: .displayInline, children: [refreshAction, signOutAction])
            case .yandexMusic:
                guard SettingsManager.shared.yandexMusic.isSigned else { return }
                
                self.signButton.setTitle(Localization.Words.signOut.localization, for: .normal)
            default:
                return
        }
    }
}

// MARK: -
// MARK: Actions
fileprivate extension ServiceSignTableViewCell {
    @objc func signAction(_ sender: UIButton) {
        switch self.type.service {
            case .soundcloud:
                guard !SettingsManager.shared.soundcloud.isSigned else { return }
            case .yandexMusic:
                guard !SettingsManager.shared.yandexMusic.isSigned else { 
                    SettingsManager.shared.yandexMusic.signOut()
                    self.delegate?.reloadCells(at: self.section)
                    return
                }
            default:
                return
        }
        
        MainCoordinator.shared.presentWebController(type: self.webViewType, delegate: self)
    }
}

// MARK: -
// MARK: WebViewControllerDelegate
extension ServiceSignTableViewCell: WebViewControllerDelegate {
    func viewDidDisappear() {
        switch self.type.service {
            case .soundcloud:
                MainCoordinator.shared.currentViewController?.presentSpinner()
                SoundcloudProvider.shared.signIn { [weak self] tokens in
                    SoundcloudProvider.shared.userInfo(accessToken: tokens.accessToken) { [weak self] userInfo in
                        MainCoordinator.shared.currentViewController?.dismissSpinner()
                        SettingsManager.shared.soundcloud.updateUserInfo(userInfo)
                        SettingsManager.shared.soundcloud.saveTokens(tokens)
                        
                        AlertView.shared.present(
                            title: Localization.Lines.successSignIn.localization(with: "Soundcloud"),
                            alertType: .done,
                            system: .iOS16AppleMusic
                        )
                        
                        if let self {
                            self.delegate?.reloadCells(at: self.section)
                        } else {
                            PulseProvider.shared.sendNewLog(
                                NewLogModel(
                                    screenId: self?.screenId?.appendingPathComponent("soundcloud"),
                                    errorType: .ui,
                                    trace: Thread.simpleCallStackSymbols,
                                    logError: .soundcloudSignInCellDidNotRefresh
                                )
                            )
                        }
                        
                        PulseProvider.shared.syncTracks()
                    } failure: { error in
                        MainCoordinator.shared.currentViewController?.dismissSpinner()
                        AlertView.shared.presentError(
                            error: error?.message ?? Localization.Lines.unknownError.localization(with: "Soundcloud"),
                            system: .iOS16AppleMusic
                        )
                    }
                } failure: { error in
                    MainCoordinator.shared.currentViewController?.dismissSpinner()
                    AlertView.shared.presentError(
                        error: error?.message ?? Localization.Lines.unknownError.localization(with: "Soundcloud"),
                        system: .iOS16AppleMusic
                    )
                }
            case .yandexMusic:
                AlertView.shared.present(
                    title: Localization.Lines.successSignIn.localization(with: Localization.Words.yandexMusic.localization),
                    alertType: .done,
                    system: .iOS16AppleMusic
                )
                
                self.delegate?.reloadCells(at: self.section)
                PulseProvider.shared.syncTracks()
            default:
                break
        }
    }
}

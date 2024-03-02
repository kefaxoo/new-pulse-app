//
//  LogoutPopUpViewController.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 2.03.24.
//

import UIKit

final class LogoutPopUpViewController: PopUpViewController {
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.tintColor = SettingsManager.shared.color.color
        button.setTitle(Localization.Words.signOut.localization, for: .normal)
        button.addTarget(self, action: #selector(yesButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.configuration = .tinted()
        button.tintColor = SettingsManager.shared.color.color
        button.setTitle(Localization.Words.cancel.localization, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
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
extension LogoutPopUpViewController {
    override func setupInterface() {
        super.setupInterface()
        self.titleLabel.text = Localization.PopUp.Logout.title.localization
    }
    
    override func setupLayout() {
        super.setupLayout()
        mainStackView.addArrangedSubview(logoutButton)
        mainStackView.addArrangedSubview(cancelButton)
    }
}

// MARK: -
// MARK: Actions
private extension LogoutPopUpViewController {
    @objc func yesButtonDidTap(_ sender: UIButton) {
        guard SettingsManager.shared.signOut(),
              LibraryManager.shared.cleanLibrary()
        else {
            self.dismissView()
            return
        }
        self.closure = {
            MainCoordinator.shared.makeAuthViewControllerAsRoot()
        }
        
        self.dismissView()
    }
    
    @objc func cancelButtonDidTap(_ sender: UIButton) {
        self.dismissView()
    }
}

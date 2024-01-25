//
//  SignInPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 31.08.23.
//

import Foundation

protocol SignInPresenterDelegate: CoversPresenterDelegate {
    func setEmail(email: String)
}

final class SignInPresenter: CoversPresenter<SignInViewController> {
    func checkTextFrom(text: String?, textFieldKind: String) -> String? {
        guard let text,
              !text.isEmpty
        else {
            AlertView.shared.presentError(
                error: Localization.Lines.textInTextFieldIsEmpty.localization(with: textFieldKind),
                system: .iOS16AppleMusic
            )
            return nil
        }
        
        return text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchEmailFromKeychain()
    }
    
    func fetchEmailFromKeychain() {
        guard !SettingsManager.shared.pulse.username.isEmpty else { return }
        
        self.delegate?.setEmail(email: SettingsManager.shared.pulse.username)
    }
    
    func loginUser(email: String?, password: String?) {
        guard let email = self.checkTextFrom(text: email, textFieldKind: Localization.Words.email.localization.lowercased()),
              let password = self.checkTextFrom(text: password, textFieldKind: Localization.Words.password.localization.lowercased())
        else { return }
        
        let pulseAccount = Credentials(email: email, password: password)
        MainCoordinator.shared.currentViewController?.presentSpinner()
        if AppEnvironment.current.isDebug || SettingsManager.shared.localFeatures.newSign?.prod ?? false {
            PulseProvider.shared.loginUserV3(credentials: pulseAccount.withEncryptedPassword, signMethod: .email) { loginUser in
                MainCoordinator.shared.currentViewController?.dismissSpinner()
                SettingsManager.shared.pulse.username = email
                SettingsManager.shared.pulse.saveTokens(loginUser.tokens)
                MainCoordinator.shared.makeTabBarAsRoot()
            } failure: { serverError, internalError in
                MainCoordinator.shared.currentViewController?.dismissSpinner()
                AlertView.shared.presentError(
                    error: LocalizationManager.shared.localizeError(
                        server: serverError,
                        internal: internalError,
                        default: Localization.Lines.unknownError.localization(with: "Pulse")),
                    system: .iOS16AppleMusic
                )
            } verifyClosure: { verificationCode in
                MainCoordinator.shared.currentViewController?.dismissSpinner()
                SettingsManager.shared.pulse.username = email
                VerifyPulseAccountPopUpViewController(verificationCode: verificationCode.verifyModel).present()
            }
        } else {
            PulseProvider.shared.loginUser(credentials: pulseAccount.withEncryptedPassword) { loginUser in
                MainCoordinator.shared.currentViewController?.dismissSpinner()
                SettingsManager.shared.pulse.username = email
                SettingsManager.shared.pulse.expireAt = loginUser.expireAt ?? 0
                SettingsManager.shared.pulse.saveCredentials(pulseAccount)
                SettingsManager.shared.pulse.saveAcceessToken(Credentials(email: email, accessToken: loginUser.accessToken))
                LibraryManager.shared.fetchLibrary()
                MainCoordinator.shared.makeTabBarAsRoot()
            } failure: { error in
                MainCoordinator.shared.currentViewController?.dismissSpinner()
                AlertView.shared.presentError(
                    error: error?.errorDescription ?? Localization.Lines.unknownError.localization(with: "Pulse"),
                    system: .iOS16AppleMusic
                )
            } verifyClosure: { verificationCode in
                MainCoordinator.shared.currentViewController?.dismissSpinner()
                SettingsManager.shared.pulse.username = email
                SettingsManager.shared.pulse.saveCredentials(pulseAccount)
                VerifyPulseAccountPopUpViewController(verificationCode: verificationCode.model).present()
            }
        }
    }
    
    func resetPassword(email: String?, password: String?) {
        guard let email = self.checkTextFrom(text: email, textFieldKind: "email"),
              let password = self.checkTextFrom(text: password, textFieldKind: "password")
        else { return }
        
        let pulseAccount = Credentials(email: email, password: password)
        MainCoordinator.shared.currentViewController?.presentSpinner()
        if AppEnvironment.current.isDebug || SettingsManager.shared.localFeatures.newSign?.prod ?? false {
            PulseProvider.shared.resetPasswordV3(credentials: pulseAccount.withEncryptedPassword) { resetPassword in
                MainCoordinator.shared.currentViewController?.dismissSpinner()
                SettingsManager.shared.pulse.username = email
                VerifyPulseAccountPopUpViewController(verificationCode: resetPassword.verifyModel).present()
            } failure: { serverError, internalError in
                MainCoordinator.shared.currentViewController?.dismissSpinner()
                AlertView.shared.presentError(
                    error: LocalizationManager.shared.localizeError(
                        server: serverError,
                        internal: internalError,
                        default: Localization.Lines.unknownError.localization(with: "Pulse")),
                    system: .iOS16AppleMusic
                )
            }
        } else {
            PulseProvider.shared.resetPassword(credentials: pulseAccount.withEncryptedPassword) { verificationCode in
                MainCoordinator.shared.currentViewController?.dismissSpinner()
                SettingsManager.shared.pulse.username = email
                VerifyPulseAccountPopUpViewController(verificationCode: verificationCode.model).present()
            } failure: { error in
                MainCoordinator.shared.currentViewController?.dismissSpinner()
                AlertView.shared.presentError(
                    error: error?.errorDescription ?? Localization.Lines.unknownError.localization(with: "Pulse"),
                    system: .iOS16AppleMusic
                )
            }
        }
    }
}

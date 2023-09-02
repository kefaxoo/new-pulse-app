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
            AlertView.shared.present(title: "Error", message: "Text in \(textFieldKind) is empty", alertType: .error, system: .iOS16AppleMusic)
            return nil
        }
        
        return text
    }
    
    func checkPassword(_ password: String?) -> String? {
        guard let password = self.checkTextFrom(text: password, textFieldKind: "password") else { return nil }
        
        guard NSRegularExpression(Constants.RegularExpressions.pulsePassword).isMatch(password) else {
            AlertView.shared.present(title: "Error", message: "Password doesn't meet requirements", alertType: .error, system: .iOS16AppleMusic)
            return nil
        }
        
        return password
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
        guard let email = self.checkTextFrom(text: email, textFieldKind: "email"),
              let password = self.checkPassword(password)
        else { return }
        
        let pulseAccount = Credentials(email: email, password: password)
        MainCoordinator.shared.currentViewController?.presentSpinner()
        PulseProvider.shared.loginUser(credentials: pulseAccount.withEncryptedPassword) { loginUser in
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            SettingsManager.shared.pulse.username = email
            SettingsManager.shared.pulse.saveCredentials(pulseAccount)
            SettingsManager.shared.pulse.saveAcceessToken(Credentials(email: email, accessToken: loginUser.accessToken))
        } failure: { error in
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            AlertView.shared.present(title: "Error", message: error?.errorDescription ?? "Unknown Pulse error", alertType: .error, system: .iOS16AppleMusic)
        } verifyClosure: { verificationCode in
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            SettingsManager.shared.pulse.username = email
            SettingsManager.shared.pulse.saveCredentials(pulseAccount)
            VerifyPulseAccountPopUpViewController(verificationCode: verificationCode.model).present()
        }
    }
    
    func resetPassword(email: String?, password: String?) {
        guard let email = self.checkTextFrom(text: email, textFieldKind: "email"),
              let password = self.checkPassword(password)
        else { return }
        
        let pulseAccount = Credentials(email: email, password: password)
        MainCoordinator.shared.currentViewController?.presentSpinner()
        PulseProvider.shared.resetPassword(credentials: pulseAccount) { verificationCode in
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            SettingsManager.shared.pulse.username = email
            VerifyPulseAccountPopUpViewController(verificationCode: verificationCode.model).present()
        } failure: { error in
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            AlertView.shared.present(title: "Error", message: error?.errorDescription ?? "Unknown Pulse error", alertType: .error, system: .iOS16AppleMusic)
        }
    }
}

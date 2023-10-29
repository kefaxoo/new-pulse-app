//
//  SignUpPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import UIKit

protocol SignUpPresenterDelegate: CoversPresenterDelegate {}

final class SignUpPresenter: CoversPresenter<SignUpViewController> {
    func checkTextFrom(text: String?, textFieldKind: String) -> String? {
        guard let text,
              !text.isEmpty
        else {
            AlertView.shared.presentError(error: "Text in \(textFieldKind) is empty", system: .iOS16AppleMusic)
            return nil
        }
        
        return text
    }
    
    func checkPassword(_ password: String?) -> String? {
        guard let password = self.checkTextFrom(text: password, textFieldKind: "password") else { return nil }
        
        guard NSRegularExpression(Constants.RegularExpressions.pulsePassword.rawValue).isMatch(password) else {
            AlertView.shared.presentError(error: "Password doesn't meet requirements", system: .iOS16AppleMusic)
            return nil
        }
        
        return password
    }
    
    func createUser(email: String?, password: String?) {
        guard let email = self.checkTextFrom(text: email, textFieldKind: "email"),
              let password = self.checkPassword(password)
        else { return }
        
        let pulseAccount = Credentials(email: email, password: password)
        MainCoordinator.shared.currentViewController?.presentSpinner()
        PulseProvider.shared.createUserV2(credentials: pulseAccount.withEncryptedPassword) { createUser in
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            SettingsManager.shared.pulse.username = email
            SettingsManager.shared.pulse.saveCredentials(pulseAccount)
            VerifyPulseAccountPopUpViewController(verificationCode: createUser.model).present()
        } failure: { error in
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            // TODO: Replace with localization from server
            AlertView.shared.presentError(error: error?.message ?? "Unknown Pulse error", system: .iOS16AppleMusic)
        }
    }
}

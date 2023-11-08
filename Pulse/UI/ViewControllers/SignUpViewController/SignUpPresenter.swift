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
            AlertView.shared.presentError(
                error: Localization.Lines.textInTextFieldIsEmpty.localization(with: textFieldKind),
                system: .iOS16AppleMusic
            )
            return nil
        }
        
        return text
    }
    
    func checkPassword(_ password: String?) -> String? {
        guard let password = self.checkTextFrom(
            text: password,
            textFieldKind: Localization.Words.password.localization.lowercased()
        ) else { return nil }
        
        guard NSRegularExpression(Constants.RegularExpressions.pulsePassword.rawValue).isMatch(password) else {
            AlertView.shared.presentError(error: Localization.Lines.passwordDoesntMeetRequirements.localization, system: .iOS16AppleMusic)
            return nil
        }
        
        return password
    }
    
    func createUser(email: String?, password: String?) {
        guard let email = self.checkTextFrom(text: email, textFieldKind: Localization.Words.email.localization.lowercased()),
              let password = self.checkPassword(password)
        else { return }
        
        let pulseAccount = Credentials(email: email, password: password)
        MainCoordinator.shared.currentViewController?.presentSpinner()
        if AppEnvironment.current.isDebug || SettingsManager.shared.localFeatures.newSign?.prod ?? false {
            PulseProvider.shared.createUserV3(credentials: pulseAccount.withEncryptedPassword, signMethod: .email) { createUser in
                MainCoordinator.shared.currentViewController?.dismissSpinner()
                SettingsManager.shared.pulse.username = email
                VerifyPulseAccountPopUpViewController(verificationCode: createUser.verifyModel).present()
            } failure: { serverError, internalError in
                MainCoordinator.shared.currentViewController?.dismissSpinner()
                AlertView.shared.presentError(
                    error: LocalizationManager.shared.localizeError(
                        server: serverError,
                        internal: internalError,
                        default: Localization.Lines.unknownError.localization(with: "Pulse")
                    ),
                    system: .iOS16AppleMusic
                )
            }
        } else {
            PulseProvider.shared.createUser(credentials: pulseAccount.withEncryptedPassword) { createUser in
                MainCoordinator.shared.currentViewController?.dismissSpinner()
                SettingsManager.shared.pulse.username = email
                SettingsManager.shared.pulse.saveCredentials(pulseAccount)
                VerifyPulseAccountPopUpViewController(verificationCode: createUser.model).present()
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

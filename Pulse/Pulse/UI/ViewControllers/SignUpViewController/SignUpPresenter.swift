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
    
    func createUser(email: String?, password: String?) {
        guard let email = self.checkTextFrom(text: email, textFieldKind: "email"),
              let password = self.checkPassword(password)
        else { return }
        
        let pulseAccount = Credentials(email: email, password: password)
        MainCoordinator.shared.currentViewController?.presentSpinner()
        PulseProvider.shared.createUser(credentials: pulseAccount.withEncryptedPassword) { createUser in
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            VerifyPulseAccountPopUpViewController(verificationCode: createUser).present()
        } failure: { error in
            MainCoordinator.shared.currentViewController?.dismissSpinner()
        }

    }
}

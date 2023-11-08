//
//  AuthPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import Foundation
import AuthenticationServices

protocol AuthPresenterDelegate: CoversPresenterDelegate {}

final class AuthPresenter: CoversPresenter<AuthViewController> {
    func pushSignUpVC() {
        MainCoordinator.shared.pushSignUpViewController(covers: covers)
    }
    
    func pushSignInVC() {
        MainCoordinator.shared.pushSignInViewController(covers: covers)
    }
    
    func signWithExternalMethod(email: String, signMethod: SignMethodType) {
        MainCoordinator.shared.currentViewController?.presentSpinner()
        PulseProvider.shared.externalSign(email: email, signMethod: signMethod) { loginUser in
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            SettingsManager.shared.pulse.username = email
            SettingsManager.shared.pulse.saveTokens(loginUser.tokens)
            MainCoordinator.shared.makeTabBarAsRoot()
        } signUpClosure: { createUser in
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            SettingsManager.shared.pulse.username = email
            VerifyPulseAccountPopUpViewController(verificationCode: createUser.verifyModel).present()
        } verifyClosure: { verifyUser in
            MainCoordinator.shared.currentViewController?.dismissSpinner()
            VerifyPulseAccountPopUpViewController(verificationCode: verifyUser.verifyModel).present()
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
    }
    
    func appleSign() {
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        let request = appleIdProvider.createRequest()
        request.requestedScopes = [.email]
        
        let appleAuthVC = ASAuthorizationController(authorizationRequests: [request])
        appleAuthVC.delegate = self.delegate
        appleAuthVC.performRequests()
    }
}

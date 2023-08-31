//
//  AuthPresenter.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import Foundation

protocol AuthPresenterDelegate: CoversPresenterDelegate {}

final class AuthPresenter: CoversPresenter<AuthViewController> {
    func pushSignUpVC() {
        MainCoordinator.shared.pushSignUpViewController(covers: covers)
    }
    
    func pushSignInVC() {
        MainCoordinator.shared.pushSignInViewController(covers: covers)
    }
}

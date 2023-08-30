//
//  AuthProvider.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import Foundation

protocol AuthProviderDelegate: CoversProviderDelegate {}

final class AuthProvider: CoversProvider<AuthViewController> {
    func pushSignUpVC() {
        MainCoordinator.shared.pushSignUpViewController(covers: covers)
    }
    
    func pushSignInVC() {
        MainCoordinator.shared.pushSignInViewController(covers: covers)
    }
}

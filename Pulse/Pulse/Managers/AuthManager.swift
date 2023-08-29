//
//  AuthManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    fileprivate init() {}
    
    func createUser(credentials: Credentials, success: @escaping((PulseCreateUser) -> ()), failure: @escaping PulseDefaultErrorClosure) {
        PulseProvider.shared.createUser(credentials: credentials, success: success, failure: failure)
    }
}

//
//  PulseModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import Foundation

final class PulseModel {
    var username: String {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.pulseUsername.rawValue) as? String ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.pulseUsername.rawValue)
        }
    }
    
    var expireAt: Int {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.pulseExpireAt.rawValue) as? Int ?? 0
        } set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.pulseExpireAt.rawValue)
        }
    }
    
    var password   : String?
    var accessToken: String? {
        didSet {
            debugLog("Pulse access token:", accessToken ?? "")
        }
    }
    
    var refreshToken: String? {
        didSet {
            debugLog("Pulse refresh token:", refreshToken ?? "")
        }
    }
    
    var isSignedIn: Bool {
        debugLog("Pulse access token:", self.accessToken ?? "")
        return !(self.accessToken?.isEmpty ?? true)
    }
    
    var shouldUpdateToken: Bool {
        return Int(Date().timeIntervalSince1970) >= self.expireAt
    }
    
    var isAccessDenied: Bool {
        get {
            return UserDefaults.standard.value(forKey: .pulseAccessDenied) as? Bool ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: .pulseAccessDenied)
        }
    }
    
    fileprivate var credentialsKeychainModel  = BaseKeychainModel(service: Constants.KeychainService.pulseCredentials.rawValue)
    fileprivate var accessTokenKeychainModel  = BaseKeychainModel(service: Constants.KeychainService.pulseToken.rawValue)
    fileprivate var refreshTokenKeychainModel = BaseKeychainModel(service: Constants.KeychainService.pulseRefreshToken.rawValue)
    
    init() {
        if let password = credentialsKeychainModel.getCredentials(username: username)?.withEncryptedPassword.password {
            self.password = password
        }
        
        if let accessToken = accessTokenKeychainModel.getCredentials(username: username)?.password {
            self.accessToken = accessToken
        }
        
        if let refreshToken = refreshTokenKeychainModel.getCredentials(username: username)?.password {
            self.refreshToken = refreshToken
        }
    }
    
    func saveCredentials(_ credentials: Credentials) {
        guard self.credentialsKeychainModel.saveCredentials(credentials) else { return }
        
        self.password = credentials.password
    }
    
    func saveAcceessToken(_ credentials: Credentials) {
        guard self.accessTokenKeychainModel.saveCredentials(credentials) else { return }
        
        self.accessToken = credentials.password
    }
    
    func updateAccessToken(_ accessToken: String) {
        guard self.accessTokenKeychainModel.updatePassword(credentials: Credentials(email: self.username, accessToken: accessToken)) else { return }
        
        self.accessToken = accessToken
    }
    
    func saveRefreshToken(_ credentials: Credentials) {
        guard self.refreshTokenKeychainModel.saveCredentials(credentials) else { return }
        
        self.refreshToken = credentials.password
    }
    
    func updateRefreshToken(_ refreshToken: String) {
        guard self.refreshTokenKeychainModel.updatePassword(credentials: Credentials(email: self.username, accessToken: refreshToken)) else { return }
        
        self.refreshToken = refreshToken
    }
    
    func updateTokens(_ tokens: PulseAuthorizationInfo) {
        self.expireAt = tokens.expireAt
        self.updateAccessToken(tokens.accessToken)
        self.updateRefreshToken(tokens.refreshToken)
    }
    
    func saveTokens(_ tokens: PulseAuthorizationInfo) {
        self.expireAt = tokens.expireAt
        self.saveAcceessToken(Credentials(email: self.username, accessToken: tokens.accessToken))
        self.saveRefreshToken(Credentials(email: self.username, accessToken: tokens.refreshToken))
    }
    
    @discardableResult func signOut() -> Bool {
        credentialsKeychainModel.deleteAccount(username: username)
        accessTokenKeychainModel.deleteAccount(username: username)
        refreshTokenKeychainModel.deleteAccount(username: username)
        
        username     = ""
        password     = nil
        accessToken  = nil
        refreshToken = nil
        return true
    }
    
    func isUserBlocked(completion: @escaping(() -> ())) {
        if NetworkManager.shared.isReachable {
            PulseProvider.shared.isUserBlocked { [weak self] isUserBlocked in
                self?.isAccessDenied = isUserBlocked
                if isUserBlocked {
                    MainCoordinator.shared.makeBlockScreenAsRoot()
                } else {
                    completion()
                }
            }
        } else if self.isAccessDenied {
            MainCoordinator.shared.makeBlockScreenAsRoot()
        } else {
            completion()
        }
    }
}

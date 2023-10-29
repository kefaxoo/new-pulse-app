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
        return (self.accessToken?.count ?? 0) != 0
    }
    
    var shouldUpdateToken: Bool {
        return Int(Date().timeIntervalSince1970) >= self.expireAt
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
    
    func signOut() -> Bool {
        guard credentialsKeychainModel.deleteAccount(username: username),
              accessTokenKeychainModel.deleteAccount(username: username),
              refreshTokenKeychainModel.deleteAccount(username: username)
        else { return false }
        
        username     = ""
        password     = nil
        accessToken  = nil
        refreshToken = nil
        return true
    }
}

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
    var accessToken: String?
    
    fileprivate var credentialsKeychainModel = BaseKeychainModel(service: Constants.KeychainService.pulseCredentials.rawValue)
    fileprivate var accessTokenKeychainModel = BaseKeychainModel(service: Constants.KeychainService.pulseToken.rawValue)
    
    init() {
        if let password = credentialsKeychainModel.getCredentials(username: username)?.withEncryptedPassword.password {
            self.password = password
        }
        
        if let accessToken = accessTokenKeychainModel.getCredentials(username: username)?.password {
            self.accessToken = accessToken
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
    
    func signOut() -> Bool {
        guard credentialsKeychainModel.deleteAccount(username: username),
              accessTokenKeychainModel.deleteAccount(username: username)
        else { return false }
        
        username = ""
        return true
    }
}

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
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKey.pulseUsername) as? String ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKey.pulseUsername)
        }
    }
    
    var password   : String?
    var accessToken: String?
    
    fileprivate var credentialsKeychainModel = BaseKeychainModel(service: Constants.KeychainService.pulseCredentials)
    fileprivate var accessTokenKeychainModel = BaseKeychainModel(service: Constants.KeychainService.pulseToken)
    
    init() {
        if let password = credentialsKeychainModel.getCredentials(username: username)?.password {
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
    
    func signOut() -> Bool {
        guard credentialsKeychainModel.deleteAccount(username: username),
              accessTokenKeychainModel.deleteAccount(username: username)
        else { return false }
        
        username = ""
        return true
    }
}

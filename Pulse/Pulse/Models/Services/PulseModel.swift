//
//  PulseModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import Foundation

struct PulseModel {
    static var username: String {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKey.pulseUsername) as? String ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKey.pulseUsername)
        }
    }
    
    var username   : String
    var password   : String?
    var accessToken: String?
    
    fileprivate let credentialsKeychainModel = BaseKeychainModel(service: Constants.KeychainService.pulseCredentials)
    fileprivate let accessTokenKeychainModel = BaseKeychainModel(service: Constants.KeychainService.pulseToken)
    
    init() {
        self.username = PulseModel.username
        if let password = credentialsKeychainModel.getCredentials(username: username)?.password {
            self.password = password
        }
        
        if let accessToken = accessTokenKeychainModel.getCredentials(username: username)?.password {
            self.accessToken = accessToken
        }
    }
}

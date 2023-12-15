//
//  SoundcloudModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import UIKit

enum SoundcloudSourceType: String {
    case muffon = "muffon"
    case soundcloud = "soundcloud"
    case none = ""
    
    static var allCases: [SoundcloudSourceType] {
        var allCases: [SoundcloudSourceType] = [.muffon]
        if SettingsManager.shared.soundcloud.isSigned {
            allCases.append(.soundcloud)
        }
        
        return allCases
    }
    
    var buttonTitle: String {
        switch self {
            case .muffon:
                return "Muffon"
            case .soundcloud:
                return "Soundcloud"
            case .none: 
                return ""
        }
    }
    
    var title: String {
        switch self {
            case .muffon:
                return "Current source: Muffon"
            case .soundcloud:
                return "Current source: Soundcloud"
            case .none:
                return ""
        }
    }
    
    var description: String {
        switch self {
            case .muffon:
                return "Current country: United Kingdom 🇬🇧"
            case .soundcloud:
                return "Current country: \(NetworkManager.shared.country ?? "United States") \(NetworkManager.shared.countryCode.emojiFlag)"
            case .none:
                return ""
        }
    }
    
    func isEqual(to source: SoundcloudSourceType) -> UIMenuElement.State {
        return source == self ? .on : .off
    }
}

final class SoundcloudModel {
    var signToken: String = ""
    
    var accessToken: String? {
        didSet {
            debugLog("Soundcloud access token:", accessToken ?? "")
        }
    }
    
    var refreshToken: String?
    
    var userId: Int {
        get {
            return Int(UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.soundcloudUserId.rawValue) as? String ?? "") ?? -1
        }
        set {
            UserDefaults.standard.setValue(String(newValue), forKey: Constants.UserDefaultsKeys.soundcloudUserId.rawValue)
        }
    }
    
    var username: String {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.soundcloudUser.rawValue) as? String ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.soundcloudUser.rawValue)
        }
    }
    
    var isSigned: Bool {
        return self.accessToken != nil
    }
    
    fileprivate var accessTokenKeychainModel = BaseKeychainModel(service: Constants.KeychainService.soundcloudAccessToken.rawValue)
    fileprivate var refreshTokenKeychainModel = BaseKeychainModel(service: Constants.KeychainService.soundcloudRefreshToken.rawValue)
    
    init() {
        if let accessToken = accessTokenKeychainModel.getCredentials(username: String(self.userId))?.password {
            self.accessToken = accessToken
        }
        
        if let refreshToken = refreshTokenKeychainModel.getCredentials(username: String(self.userId))?.password {
            self.refreshToken = refreshToken
        }
    }
    
    func saveTokens(_ tokens: SoundcloudToken) {
        guard self.accessTokenKeychainModel.saveCredentials(Credentials(userId: self.userId, accessToken: tokens.accessToken)),
              self.refreshTokenKeychainModel.saveCredentials(Credentials(userId: self.userId, accessToken: tokens.refreshToken))
        else { return }
        
        self.accessToken = tokens.accessToken
        self.refreshToken = tokens.refreshToken
    }
    
    func updateTokens(_ tokens: SoundcloudToken) {
        guard self.accessTokenKeychainModel.updatePassword(credentials: Credentials(userId: self.userId, accessToken: tokens.accessToken)),
              self.refreshTokenKeychainModel.updatePassword(credentials: Credentials(userId: self.userId, accessToken: tokens.refreshToken))
        else { return }
        
        self.accessToken = tokens.accessToken
        self.refreshToken = tokens.refreshToken
    }
    
    func updateUserInfo(_ userInfo: SoundcloudUserInfo) {
        self.userId   = userInfo.id
        self.username = userInfo.username
    }
    
    func signOut() -> Bool {
        guard accessTokenKeychainModel.deleteAccount(username: String(self.userId)),
              refreshTokenKeychainModel.deleteAccount(username: String(self.userId))
        else { return false }
        
        userId        = -1
        accessToken   = nil
        refreshToken  = nil
        currentSource = .muffon
        return true
    }
    
    var currentSource: SoundcloudSourceType {
        get {
            return SoundcloudSourceType(
                rawValue: UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.soundcloudSource.rawValue) as? String ?? "empty"
            ) ?? .muffon
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: Constants.UserDefaultsKeys.soundcloudSource.rawValue)
        }
    }
}

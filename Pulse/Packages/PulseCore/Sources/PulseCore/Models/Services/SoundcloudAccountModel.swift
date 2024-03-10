//
//  SoundcloudAccountModel.swift
//
//
//  Created by Bahdan Piatrouski on 10.03.24.
//

import UIKit
import PulseBaseItems

public enum SoundcloudSources: String {
    case muffon
    case soundcloud
    case none = ""
    
    public static var allCases: [SoundcloudSources] {
        var allCases: [SoundcloudSources] = [.muffon]
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
    
    func isEqual(toSource source: SoundcloudSources) -> UIMenuElement.State {
        return source == self ? .on : .off
    }
}

public final class SoundcloudAccountModel: ServiceAccountModel {
    public var signToken = ""
    
    public var accessToken: String? {
        didSet {
            debugPrint("Soundcloud access token: \(accessToken ?? "")")
        }
    }
    
    public var refreshToken: String?
    
    public var userId: Int {
        get {
            return UserDefaults.standard.value(forKey: .soundcloudUserId) as? Int ?? -1
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: .soundcloudUserId)
        }
    }
    
    public var username: String {
        get {
            return UserDefaults.standard.value(forKey: .soundcloudUser) as? String ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: .soundcloudUser)
        }
    }
    
    public var isSigned: Bool {
        return self.accessToken != nil
    }
    
    var currentSource: SoundcloudSources {
        get {
            return SoundcloudSources(rawValue: UserDefaults.standard.value(forKey: .soundcloudSource) as? String ?? "") ?? .muffon
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: .soundcloudSource)
        }
    }
    
    public var accessTokenKeychainModel = KeychainModel(service: .soundcloudAccessToken)
    private var refreshTokenKeychainModel = KeychainModel(service: .soundcloudRefreshToken)
    
    init() {
        if let accessToken = accessTokenKeychainModel.getCredentials(forUsername: String(self.userId))?.password {
            self.accessToken = accessToken
        }
        
        if let refreshToken = refreshTokenKeychainModel.getCredentials(forUsername: String(self.userId))?.password {
            self.refreshToken = refreshToken
        }
    }
    
    @discardableResult public func saveOrUpdateTokens(_ tokens: SoundcloudToken) -> Bool {
        guard self.accessTokenKeychainModel.saveOrUpdateAccount(credentials: Credentials(userId: self.userId, accessToken: tokens.accessToken)),
              self.refreshTokenKeychainModel.saveOrUpdateAccount(credentials: Credentials(userId: self.userId, accessToken: tokens.refreshToken))
        else { return false }
        
        self.accessToken = tokens.accessToken
        self.refreshToken = tokens.refreshToken
        return true
    }
    
    public func updateUserInfo(_ userInfo: SoundcloudUserInfo) {
        self.userId = userInfo.id
        self.username = userInfo.username
    }
    
    @discardableResult public func signOut() -> Bool {
        guard accessTokenKeychainModel.deleteAccount(username: String(self.userId)),
              refreshTokenKeychainModel.deleteAccount(username: String(self.userId))
        else { return false }
        
        userId = -1
        accessToken = nil
        refreshToken = nil
        currentSource = .muffon
        return true
    }
}

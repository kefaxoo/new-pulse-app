//
//  YandexMusicModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 13.12.23.
//

import UIKit

enum YandexMusicSourceType: String {
    case muffon = "muffon"
    case yandexMusic = "yandexMusic"
    case none = ""
    
    static var allCases: [YandexMusicSourceType] {
        var allCases: [YandexMusicSourceType] = [.muffon]
        if SettingsManager.shared.yandexMusic.isSigned {
            allCases.append(.yandexMusic)
        }
        
        return allCases
    }
    
    var buttonTitle: String {
        switch self {
            case .muffon:
                return "Muffon"
            case .yandexMusic:
                return "Yandex Music"
            case .none:
                return ""
        }
    }
    
    var title: String {
        switch self {
            case .muffon:
                return "Current source: Muffon"
            case .yandexMusic:
                return "Current source: Yandex Music"
            case .none:
                return ""
        }
    }
    
    var description: String {
        switch self {
            case .muffon:
                return "Current country: Russia 🇷🇺"
            case .yandexMusic:
                return "Current country: \(NetworkManager.shared.country ?? "United States") \(NetworkManager.shared.countryCode.emojiFlag)"
            case .none:
                return ""
        }
    }
    
    func isEqual(to source: YandexMusicSourceType) -> UIMenuElement.State {
        return source == self ? .on : .off
    }
}

final class YandexMusicModel {
    var displayName: String {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.yandexMusicDisplayName.rawValue) as? String ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.yandexMusicDisplayName.rawValue)
        }
    }
    
    var id: Int {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.yandexMusicUid.rawValue) as? Int ?? 0
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.yandexMusicUid.rawValue)
        }
    }
    
    var accessToken: String? {
        didSet {
            debugLog("Yandex Music access token:", accessToken ?? "")
        }
    }
    
    var isSigned: Bool {
        return self.accessToken != nil
    }
    
    fileprivate var accessTokenKeychainModel = BaseKeychainModel(service: YandexMusicModel.keychainService)
    
    fileprivate static let keychainService = Constants.KeychainService.yandexMusicAccessToken.rawValue
    
    init() {
        if let accessToken = accessTokenKeychainModel.getCredentials(username: Self.keychainService)?.password {
            self.accessToken = accessToken
        }
    }
    
    func saveToken(_ token: String) {
        guard self.accessTokenKeychainModel.saveCredentials(Credentials(service: Self.keychainService, accessToken: token)) else { return }
        
        self.accessToken = token
    }
    
    func signOut() -> Bool {
        guard accessTokenKeychainModel.deleteAccount(username: Self.keychainService) else { return false }
        
        id            = 0
        accessToken   = nil
        currentSource = .muffon
        return true
    }
    
    var currentSource: YandexMusicSourceType {
        get {
            return YandexMusicSourceType(
                rawValue: UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.yandexMusicSource.rawValue) as? String ?? "empty"
            ) ?? .muffon
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: Constants.UserDefaultsKeys.yandexMusicSource.rawValue)
        }
    }
}

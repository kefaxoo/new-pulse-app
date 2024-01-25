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
                return Localization.Words.yandexMusic.localization
            case .none:
                return ""
        }
    }
    
    var title: String {
        return Localization.Lines.currentSource.localization(with: self.buttonTitle)
    }
    
    var description: String {
        switch self {
            case .muffon:
                return Localization.Lines.currentCountry.localization(with: "Russia 🇷🇺")
            case .yandexMusic:
                return Localization.Lines.currentCountry.localization(
                    with: "\(NetworkManager.shared.country ?? "United States") \(NetworkManager.shared.countryCode.emojiFlag)"
                )
            case .none:
                return ""
        }
    }
    
    func isEqual(to source: YandexMusicSourceType) -> UIMenuElement.State {
        return source == self ? .on : .off
    }
}

final class YandexMusicModel {
    enum Quality: Int, CaseIterable {
        case lq = 128
        case mq = 192
        case hq = 320
        
        var fileExtension: String {
            return self == .lq ? "m4a" : "mp3"
        }
        
        var title: String {
            switch self {
                case .lq:
                    return Localization.Enums.YandexMusicQuality.lq.localization
                case .mq:
                    return Localization.Enums.YandexMusicQuality.mq.localization
                case .hq:
                    return Localization.Enums.YandexMusicQuality.hq.localization
            }
        }
        
        func isEqual(to type: Quality) -> UIMenuElement.State {
            return self == type ? .on : .off
        }
    }
    
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
    
    var hasPlus: Bool {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.yandexMusicIsPlus.rawValue) as? Bool ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaultsKeys.yandexMusicIsPlus.rawValue)
        }
    }
    
    var isSigned: Bool {
        return self.accessToken != nil
    }
    
    var streamingQuality: Quality {
        get {
            return Quality(rawValue: UserDefaults.standard.value(forKey: .yandexMusicStreamingQuality) as? Int ?? 0) ?? .lq
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: .yandexMusicStreamingQuality)
        }
    }
    
    var downloadQuality: Quality {
        get {
            return Quality(rawValue: UserDefaults.standard.value(forKey: .yandexMusicDownloadQuality) as? Int ?? 0) ?? .lq
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: .yandexMusicDownloadQuality)
        }
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
    
    @discardableResult func signOut() -> Bool {
        accessTokenKeychainModel.deleteAccount(username: Self.keychainService)
        
        id            = 0
        accessToken   = nil
        currentSource = .muffon
        hasPlus       = false
        return true
    }
    
    var currentSource: YandexMusicSourceType {
        get {
            return YandexMusicSourceType(
                rawValue: UserDefaults.standard.value(forKey: Constants.UserDefaultsKeys.yandexMusicSource.rawValue) as? String ?? ""
            ) ?? .muffon
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: Constants.UserDefaultsKeys.yandexMusicSource.rawValue)
        }
    }
    
    func checkPlusSubscription() {
        YandexMusicProvider.shared.fetchAccountInfo(success: { self.hasPlus = $0.plus.hasPlus })
    }
}

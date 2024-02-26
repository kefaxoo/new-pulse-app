//
//  SettingsModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 26.02.24.
//

import UIKit

final class SettingsModel {
    // MARK: - Features
    let featuresKeys: [String] = []
    var localFeatures = LocalFeaturesModel()
    
    init() {}
}

// MARK: -
// MARK: Yandex Music
extension SettingsModel {
    var yandexMusicLike: Bool {
        get {
            return UserDefaults.standard.value(forKey: .yandexMusicLike) as? Bool ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: .yandexMusicLike)
        }
    }
}

// MARK: -
// MARK: Features
extension SettingsModel {
    var featuresLastUpdate: Int {
        get {
            return UserDefaults.standard.value(forKey: .featuresLastUpdate) as? Int ?? 0
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: .featuresLastUpdate)
        }
    }
    
    var shouldUpdateFeatures: Bool {
        guard AppEnvironment.current.isRelease else { return true }
        
        return Int(Date().timeIntervalSince1970) - self.featuresLastUpdate >= 86400
    }
}

// MARK: -
// MARK: Unique Device ID
extension SettingsModel {
    var udid: String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
}

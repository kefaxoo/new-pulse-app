//
//  SettingsManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import Foundation

final class SettingsManager {
    static let shared = SettingsManager()
    
    fileprivate init() {}
    
    var pulse = PulseModel()
    var color: ColorType {
        get {
            return ColorType(
                rawValue: UserDefaults.standard.value(forKey: Constants.UserDefaultsKey.colorType) as? String ?? ""
            ) ?? .purple
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: Constants.UserDefaultsKey.colorType)
        }
    }
}

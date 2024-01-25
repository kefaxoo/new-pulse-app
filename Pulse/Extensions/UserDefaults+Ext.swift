//
//  UserDefaults+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.01.24.
//

import Foundation

extension UserDefaults {
    func value(forKey key: Constants.UserDefaultsKeys) -> Any? {
        return self.value(forKey: key.rawValue)
    }
    
    func setValue(_ value: Any?, forKey key: Constants.UserDefaultsKeys) {
        self.setValue(value, forKey: key.rawValue)
    }
}

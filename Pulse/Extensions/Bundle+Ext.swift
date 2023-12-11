//
//  Bundle+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.10.23.
//

import Foundation

extension Bundle {
    var releaseVersion: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersion: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    
    static let enLocalizationPath: String? = Bundle.main.path(forResource: "en", ofType: "lproj")
    
    static var localizedBundle: Bundle! {
        var locale: String?
        if #available(iOS 16.0, *) {
            locale = Locale.current.language.languageCode?.identifier
        } else {
            locale = Locale.current.languageCode
        }
        
        if let locale {
            if locale == "ru" {
                return Bundle(path: Bundle.main.path(forResource: "ru", ofType: "lproj")!)
            } else {
                return Bundle(path: self.enLocalizationPath!)
            }
        } else {
            return Bundle(path: self.enLocalizationPath!)
        }
    }
}

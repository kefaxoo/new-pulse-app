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
        return Bundle(path: Bundle.main.path(forResource: Locale.current.isoLanguageCode, ofType: "lproj") ?? self.enLocalizationPath!)
    }
}

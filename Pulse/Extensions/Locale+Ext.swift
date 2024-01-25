//
//  Locale+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 26.01.24.
//

import Foundation

extension Locale {
    static let languageCodeWithLocalization = ["en", "ru"]
    
    var isoLanguageCode: String {
        var locale: String?
        if #available(iOS 16.0, *) {
            locale = Locale.current.language.languageCode?.identifier
        } else {
            locale = Locale.current.languageCode
        }
        
        if let locale,
           !Self.languageCodeWithLocalization.contains(locale) {
            return "en"
        }
        
        return locale ?? "en"
    }
}

//
//  SettingsSectionType.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 4.09.23.
//

import Foundation

enum SettingSectionType {
    case general
    case appearance
    case soundcloud
    case help
    case debug
    
    static var allCases: [SettingSectionType] {
        var allCases: [SettingSectionType] = [.general, .appearance, .soundcloud]
#if !RELEASE_P
        allCases.append(.debug)
#endif
        
        return allCases
    }
    
    var title: String {
        switch self {
            case .general:
                return "General"
            case .appearance:
                return "Appearance"
            case .soundcloud:
                return "Soundcloud"
            case .help:
                return "Help"
            case .debug:
                return "Debug"
        }
    }
    
    var settings: [SettingType] {
        switch self {
            case .general:
                return [.autoDownload]
            case .appearance:
                return [.accentColor]
            case .soundcloud:
                var array: [SettingType] = [.soundcloudSign]
                if SettingsManager.shared.soundcloud.isSigned {
                    array.append(.soundcloudLike)
                    array.append(.soundcloudSource)
                }
                
                return array
            case .help:
                return [.about]
            case .debug:
                return [.appEnvironment, .appInfo]
        }
    }
}

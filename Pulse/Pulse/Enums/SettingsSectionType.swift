//
//  SettingsSectionType.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 4.09.23.
//

import Foundation

enum SettingSectionType: CaseIterable {
    case general
    case appearance
    case soundcloud
    case help
    
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
                }
                
                return array
            case .help:
                return [.about]
        }
    }
}

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
    case help
    
    var title: String {
        switch self {
            case .general:
                return "General"
            case .appearance:
                return "Appearance"
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
            case .help:
                return [.about]
        }
    }
}

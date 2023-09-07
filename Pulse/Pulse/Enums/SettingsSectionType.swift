//
//  SettingsSectionType.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 4.09.23.
//

import Foundation

enum SettingSectionType: CaseIterable {
    case general
    case help
    
    var title: String {
        switch self {
            case .general:
                return "General"
            case .help:
                return "Help"
        }
    }
    
    var settings: [SettingType] {
        switch self {
            case .general:
                return [.adultContent, .import, .canvasEnabled, .autoDownload]
            case .help:
                return [.about]
        }
    }
}

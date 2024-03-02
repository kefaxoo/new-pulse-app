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
    case yandexMusic
    
    static var allCases: [SettingSectionType] {
        var allCases: [SettingSectionType] = [.general, .appearance, .soundcloud, .yandexMusic]
        
#if !RELEASE_P
        allCases.append(.debug)
#endif
        
        return allCases
    }
    
    var title: String {
        switch self {
            case .general:
                return Localization.Words.general.localization
            case .appearance:
                return Localization.Words.appearance.localization
            case .soundcloud:
                return "Soundcloud"
            case .help:
                return Localization.Words.help.localization
            case .debug:
                return "Debug"
            case .yandexMusic:
                return Localization.Words.yandexMusic.localization
        }
    }
    
    var settings: [SettingType] {
        switch self {
            case .general:
                return [.autoDownload, .canvasEnabled]
            case .appearance:
                return [.accentColor, .appearance]
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
                return [.yandexMusicToken, .appEnvironment, .appInfo]
            case .yandexMusic:
                var array: [SettingType] = [.yandexMusicSign]
                if SettingsManager.shared.yandexMusic.isSigned {
                    array.append(.yandexMusicLike)
                    array.append(.yandexMusicSource)
                    array.append(.yandexMusicStreamingQuality)
                    array.append(.yandexMusicDownloadQuality)
                }
                
                return array
        }
    }
}

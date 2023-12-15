//
//  SettingType.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 4.09.23.
//

import UIKit

enum SettingType {
    case adultContent
    case `import`
    case canvasEnabled
    case autoDownload
    case accentColor
    case soundcloudSign
    case about
    case none
    case soundcloudLike
    case soundcloudSource
    case appEnvironment
    case appInfo
    case yandexMusicSign
    case yandexMusicSource
    case yandexMusicLike
    
    var cellType: CellType {
        switch self {
            case .adultContent, .canvasEnabled, .autoDownload:
                return .switch
            case .import, .appInfo:
                return .text
            case .about:
                return .chevronText
            case .accentColor, .soundcloudSource, .appEnvironment, .yandexMusicSource:
                return .tintedButton
            case .soundcloudSign, .yandexMusicSign:
                return .service
            case .soundcloudLike, .yandexMusicLike:
                return .switch
            case .none:
                return .none
        }
    }
    
    var title: String {
        switch self {
            case .adultContent:
                return "Limit access to content"
            case .import:
                return "Import your media library"
            case .canvasEnabled:
                return "Canvas in the app"
            case .autoDownload:
                return "Auto-download tracks"
            case .about:
                return "About"
            case .accentColor:
                return "Color of the application"
            case .soundcloudSign:
                if SettingsManager.shared.soundcloud.isSigned {
                    return "User: \(SettingsManager.shared.soundcloud.username)"
                } else {
                    return "Sign in Soundcloud"
                }
            case .yandexMusicSign:
                if SettingsManager.shared.yandexMusic.isSigned {
                    return "User: \(SettingsManager.shared.yandexMusic.displayName)"
                } else {
                    return "Sign in Yandex Music"
                }
            case .none:
                return ""
            case .soundcloudLike:
                return "Like track in Soundcloud"
            case .yandexMusicLike:
                return "Like track in Yandex Music"
            case .soundcloudSource:
                return SettingsManager.shared.soundcloud.currentSource.title
            case .yandexMusicSource:
                return SettingsManager.shared.yandexMusic.currentSource.title
            case .appEnvironment:
                return "App Environment Mode"
            case .appInfo:
                return "App version: \(Bundle.main.releaseVersion ?? "nil")"
        }
    }
    
    var description: String? {
        switch self {
            case .adultContent:
                return "We won't play tracks, which has explicit content"
            case .import:
                return "Move your library from other services to Pulse"
            case .canvasEnabled:
                return "Canvases are shown in the player where artists' photos, cover art and videos come to life"
            case .autoDownload:
                return "Tracks you liked are immediately downloaded so you can listen offline"
            case .accentColor:
                return "Choose the color of the application based on your mood"
            case .soundcloudLike:
                return "All tracks that have been added to the library will be added to the Soundcloud library"
            case .yandexMusicLike:
                return "All tracks that have been added to the library will be added to the Yandex Music library"
            case .soundcloudSource:
                return SettingsManager.shared.soundcloud.currentSource.description
            case .yandexMusicSource:
                return SettingsManager.shared.yandexMusic.currentSource.description
            case .appInfo:
                return "Build number: \(Bundle.main.buildVersion ?? "nil")"
            default:
                return nil
        }
    }
    
    var selectionStyle: UITableViewCell.SelectionStyle {
        switch self {
            case .import, .about:
                return .gray
            default:
                return .none
        }
    }
    
    var id: String {
        switch self.cellType {
            case .switch:
                return SwitchTableViewCell.id
            case .text:
                return TextTableViewCell.id
            case .chevronText:
                return ChevronTableViewCell.id
            case .service:
                return ServiceSignTableViewCell.id
            case .tintedButton:
                return ButtonTableViewCell.id
            case .none:
                return ""
        }
    }
    
    var state: Bool? {
        switch self {
            case .adultContent:
                return SettingsManager.shared.isAdultContentEnabled
            case .canvasEnabled:
                return SettingsManager.shared.isCanvasesEnabled
            case .autoDownload:
                return SettingsManager.shared.autoDownload
            case .soundcloudLike:
                return SettingsManager.shared.soundcloudLike
            case .yandexMusicLike:
                return SettingsManager.shared.yandexMusicLike
            default:
                return nil
        }
    }
    
    func setState(_ state: Bool) {
        switch self {
            case .adultContent:
                SettingsManager.shared.isAdultContentEnabled = state
            case .canvasEnabled:
                SettingsManager.shared.isCanvasesEnabled = state
            case .autoDownload:
                SettingsManager.shared.autoDownload = state
            case .soundcloudLike:
                SettingsManager.shared.soundcloudLike = state
            case .yandexMusicLike:
                SettingsManager.shared.yandexMusicLike = state
            default:
                return
        }
    }
    
    var service: ServiceType {
        switch self {
            case .soundcloudSign:
                return .soundcloud
            case .yandexMusicSign:
                return .yandexMusic
            default:
                return .none
        }
    }
    
    var isMenu: Bool {
        switch self {
            case .accentColor, .soundcloudSource, .appEnvironment, .yandexMusicSource:
                return true
            default:
                return false
        }
    }
    
    var buttonName: String {
        switch self {
            case .accentColor:
                return SettingsManager.shared.color.title
            case .soundcloudSource:
                return SettingsManager.shared.soundcloud.currentSource.buttonTitle
            case .yandexMusicSource:
                return SettingsManager.shared.yandexMusic.currentSource.buttonTitle
            case .appEnvironment:
                return AppEnvironment.current.buttonTitle
            default:
                return ""
        }
    }
}

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
    case yandexMusicStreamingQuality
    case yandexMusicDownloadQuality
    case appearance
    
    var cellType: CellType {
        switch self {
            case .adultContent, .canvasEnabled, .autoDownload:
                return .switch
            case .import, .appInfo:
                return .text
            case .about:
                return .chevronText
            case .accentColor, .soundcloudSource, .appEnvironment, .yandexMusicSource, .appearance, .yandexMusicStreamingQuality, 
                    .yandexMusicDownloadQuality:
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
                return Localization.Enums.SettingType.Title.adultContent.localization
            case .import:
                return Localization.Enums.SettingType.Title.import.localization
            case .canvasEnabled:
                return Localization.Enums.SettingType.Title.canvasEnabled.localization
            case .autoDownload:
                return Localization.Enums.SettingType.Title.autoDownload.localization
            case .about:
                return Localization.Enums.SettingType.Title.about.localization
            case .accentColor:
                return Localization.Enums.SettingType.Title.accentColor.localization
            case .soundcloudSign:
                if SettingsManager.shared.soundcloud.isSigned {
                    return Localization.Lines.user.localization(with: SettingsManager.shared.soundcloud.username)
                } else {
                    return Localization.Lines.signIn.localization(with: "Soundcloud")
                }
            case .yandexMusicSign:
                if SettingsManager.shared.yandexMusic.isSigned {
                    return Localization.Lines.user.localization(with: SettingsManager.shared.yandexMusic.displayName)
                } else {
                    return Localization.Lines.signIn.localization(with: Localization.Words.yandexMusic.localization)
                }
            case .none:
                return ""
            case .soundcloudLike:
                return Localization.Lines.likeTrackIn.localization(with: "Soundcloud")
            case .yandexMusicLike:
                return Localization.Lines.likeTrackIn.localization(with: Localization.Words.yandexMusic.localization)
            case .soundcloudSource:
                return SettingsManager.shared.soundcloud.currentSource.title
            case .yandexMusicSource:
                return SettingsManager.shared.yandexMusic.currentSource.title
            case .appEnvironment:
                return Localization.Enums.SettingType.Title.appEnvironment.localization
            case .appInfo:
                return Localization.Lines.appInfo.localization(with: Bundle.main.releaseVersion ?? "")
            case .appearance:
                return Localization.Words.appearance.localization
            case .yandexMusicStreamingQuality:
                return Localization.Enums.SettingType.Title.streamingQuality.localization
            case .yandexMusicDownloadQuality:
                return Localization.Enums.SettingType.Title.downloadQuality.localization
        }
    }
    
    var description: String? {
        switch self {
            case .adultContent:
                return Localization.Enums.SettingType.Description.adultContent.localization
            case .import:
                return Localization.Enums.SettingType.Description.import.localization
            case .canvasEnabled:
                return Localization.Enums.SettingType.Description.canvasEnabled.localization
            case .autoDownload:
                return Localization.Enums.SettingType.Description.autoDownload.localization
            case .accentColor:
                return Localization.Enums.SettingType.Description.accentColor.localization
            case .soundcloudLike:
                return Localization.Lines.likeTrackInDescription.localization(with: "Soundcloud")
            case .yandexMusicLike:
                return Localization.Lines.likeTrackInDescription.localization(with: Localization.Words.yandexMusic.localization)
            case .soundcloudSource:
                return SettingsManager.shared.soundcloud.currentSource.description
            case .yandexMusicSource:
                return SettingsManager.shared.yandexMusic.currentSource.description
            case .appInfo:
                return Localization.Lines.buildNumber.localization(with: Bundle.main.buildVersion ?? "")
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
            case .accentColor, .soundcloudSource, .appEnvironment, .yandexMusicSource, .appearance, .yandexMusicStreamingQuality, 
                    .yandexMusicDownloadQuality:
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
            case .appearance:
                return SettingsManager.shared.appearance.title
            case .yandexMusicStreamingQuality:
                return SettingsManager.shared.yandexMusic.streamingQuality.title
            case .yandexMusicDownloadQuality:
                return SettingsManager.shared.yandexMusic.downloadQuality.title
            default:
                return ""
        }
    }
}

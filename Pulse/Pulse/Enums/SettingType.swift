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
    
    var cellType: CellType {
        switch self {
            case .adultContent, .canvasEnabled, .autoDownload:
                return .switch
            case .import:
                return .text
            case .about:
                return .chevronText
            case .accentColor:
                return .colorButton
            case .soundcloudSign:
                return .service
            case .soundcloudLike:
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
                    return "Sign in soundcloud"
                }
            case .none:
                return ""
            case .soundcloudLike:
                return "Like track in Soundcloud"
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
        switch self {
            case .adultContent, .canvasEnabled, .autoDownload, .soundcloudLike:
                return SwitchTableViewCell.id
            case .import:
                return TextTableViewCell.id
            case .about:
                return ChevronTableViewCell.id
            case .accentColor:
                return ColorSettingTableViewCell.id
            case .soundcloudSign:
                return ServiceSignTableViewCell.id
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
            default:
                return
        }
    }
    
    var service: ServiceType {
        switch self {
            case .soundcloudSign:
                return .soundcloud
            default:
                return .none
        }
    }
}

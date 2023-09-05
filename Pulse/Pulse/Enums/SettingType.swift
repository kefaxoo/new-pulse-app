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
    case about
    
    var cellType: CellType {
        switch self {
            case .adultContent, .canvasEnabled, .autoDownload:
                return .switch
            case .import:
                return .text
            case .about:
                return .chevronText
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
            default:
                return nil
        }
    }
    
    var selectionStyle: UITableViewCell.SelectionStyle {
        switch self {
            case .adultContent, .canvasEnabled, .autoDownload:
                return .none
            case .import, .about:
                return .gray
        }
    }
    
    var id: String {
        switch self {
            case .adultContent, .canvasEnabled, .autoDownload:
                return SwitchTableViewCell.id
            case .import:
                return TextTableViewCell.id
            case .about:
                return ChevronTableViewCell.id
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
            default:
                return
        }
    }
}

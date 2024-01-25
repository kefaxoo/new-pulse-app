//
//  LibraryType.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 10.09.23.
//

import UIKit

enum LibraryType {
    case playlists
    case tracks
    case soundcloud
    case yandexMusic
    
    var title: String {
        switch self {
            case .playlists:
                return Localization.Words.playlists.localization
            case .tracks:
                return Localization.Words.tracks.localization
            case .soundcloud:
                return "Soundcloud"
            case .yandexMusic:
                return Localization.Words.yandexMusic.localization
        }
    }
    
    var image: UIImage? {
        switch self {
            case .playlists:
                return Constants.Images.playlists.image
            case .tracks:
                return Constants.Images.tracks.image
            case .soundcloud:
                return Constants.Images.soundcloudLogo.image
            case .yandexMusic:
                return Constants.Images.yandexMusicLogo.image
        }
    }
    
    static func allCases(by service: ServiceType) -> [LibraryType] {
        var types = [LibraryType]()
        switch service {
            case .soundcloud:
                types.append(.playlists)
                types.append(.tracks)
            case .yandexMusic:
                types.append(.tracks)
            case .none:
                types.append(.tracks)
                if SettingsManager.shared.soundcloud.isSigned {
                    types.append(.soundcloud)
                }
                
                if SettingsManager.shared.yandexMusic.isSigned {
                    types.append(.yandexMusic)
                }
            default:
                break
        }
        
        return types
    }
    
    func controllerType(service: ServiceType) -> LibraryControllerType {
        switch self {
            case .tracks:
                switch service {
                    case .soundcloud:
                        return .soundcloud
                    case .none:
                        return .library
                    case .yandexMusic:
                        return .yandexMusic
                    default:
                        return .none
                }
            case .playlists:
                switch service {
                    case .soundcloud:
                        return .soundcloud
                    default:
                        return .none
                }
            case .soundcloud:
                return .soundcloud
            case .yandexMusic:
                return .yandexMusic
        }
    }
    
    var service: ServiceType {
        switch self {
            case .playlists:
                return .none
            case .tracks:
                return .none
            case .soundcloud:
                return .soundcloud
            case .yandexMusic:
                return .yandexMusic
        }
    }
}

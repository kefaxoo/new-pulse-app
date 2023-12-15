//
//  ServiceType.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import UIKit

enum ServiceType: String {
    case vk          = "vk"
    case yandexMusic = "yandexMusic"
    case spotify     = "spotify"
    case deezer      = "deezer"
    case soundcloud  = "soundcloud"
    case none        = ""
    
    var muffonApi: String {
        switch self {
            case .vk:
                return "vk"
            case .yandexMusic:
                return "yandexmusic"
            case .spotify:
                return "spotify"
            case .deezer:
                return "deezer"
            case .soundcloud:
                return "soundcloud"
            case .none:
                return ""
        }
    }
    
    static var searchController: [ServiceType] {
        var services: [ServiceType] = [.soundcloud]
        if AppEnvironment.current.isDebug || SettingsManager.shared.localFeatures.muffonYandex?.prod ?? false {
            services.append(.yandexMusic)
        }
        
        return services
    }
    
    var title: String {
        switch self {
            case .vk:
                return "Vk"
            case .yandexMusic:
                return "Yandex Music"
            case .spotify:
                return "Spotify"
            case .deezer:
                return "Deezer"
            case .soundcloud:
                return "Soundcloud"
            case .none:
                return ""
        }
    }
    
    static func fromMuffon(_ rawValue: String) -> ServiceType {
        switch rawValue {
            case "soundcloud":
                return .soundcloud
            case "yandexmusic":
                return .yandexMusic
            default:
                return .none
        }
    }
    
    var image: UIImage? {
        switch self {
            case .soundcloud:
                return Constants.Images.soundcloudLogo.image
            case .yandexMusic:
                return Constants.Images.yandexMusicLogo.image
            default:
                return nil
        }
    }
    
    var source: SourceType {
        switch self {
            case .soundcloud:
                return SourceType.soundcloudService(SettingsManager.shared.soundcloud.currentSource)
            case .yandexMusic:
                return SourceType.yandexMusicService(SettingsManager.shared.yandexMusic.currentSource)
            default:
                return .none
        }
    }
    
    var webType: WebViewType {
        switch self {
            case .soundcloud:
                return .soundcloud
            case .yandexMusic:
                return .yandexMusic
            default:
                return .none
        }
    }
    
    var playlistsSegments: [LibraryPlaylistType] {
        switch self {
            case .soundcloud:
                return [.user, .liked]
            default:
                return []
        }
    }
}

//
//  ServiceType.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import UIKit

enum ServiceType: String {
    case vk           = "vk"
    case yandexMusic  = "yandexMusic"
    case spotify      = "spotify"
    case deezer       = "deezer"
    case soundcloud   = "soundcloud"
    case appleMusic   = "appleMusic"
    case youtube      = "youtube"
    case youtubeMusic = "youtubeMusic"
    case none         = ""
    case pulse        = "pulse"
    
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
            default:
                return ""
        }
    }
    
    static var searchController: [ServiceType] {
        var services: [ServiceType] = [.soundcloud]
        if SettingsManager.shared.yandexMusic.isSigned,
           SettingsManager.shared.yandexMusic.hasPlus {
            services.append(.yandexMusic)
        }
        
        services.append(.deezer)
        
        return services
    }
    
    var title: String {
        switch self {
            case .vk:
                return Localization.Words.vk.localization
            case .yandexMusic:
                return Localization.Words.yandexMusic.localization
            case .spotify:
                return "Spotify"
            case .deezer:
                return "Deezer"
            case .soundcloud:
                return "Soundcloud"
            case .appleMusic:
                return "Apple Music"
            case .youtube:
                return "Youtube"
            case .youtubeMusic:
                return "Youtube Music"
            case .none:
                return ""
            case .pulse:
                return ""
        }
    }
    
    static func fromMuffon(_ rawValue: String) -> ServiceType {
        switch rawValue {
            case "soundcloud":
                return .soundcloud
            case "yandexmusic":
                return .yandexMusic
            case "deezer":
                return .deezer
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
            case .pulse:
                return Constants.Images.pulseLogo.image
            case .deezer:
                return Constants.Images.deezerLogo.image
            case .appleMusic:
                return Constants.Images.appleMusicLogo.image
            case .spotify:
                return Constants.Images.spotifyLogo.image
            case .youtube:
                return Constants.Images.youtubeLogo.image
            case .youtubeMusic:
                return Constants.Images.youtubeMusicLogo.image
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
            case .deezer:
                return .muffon
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
    
    var odesliApi: String {
        switch self {
            case .yandexMusic:
                return "yandex"
            case .spotify:
                return "spotify"
            case .deezer:
                return "deezer"
            case .soundcloud:
                return "soundcloud"
            case .appleMusic:
                return "appleMusic"
            case .youtube:
                return "youtube"
            case .youtubeMusic:
                return "youtubeMusic"
            default:
                return ""
        }
    }
    
    var odesliReplacePart: String {
        switch self {
            case .yandexMusic:
                return "YANDEX_SONG::"
            case .spotify:
                return "SPOTIFY_SONG::"
            case .deezer:
                return "DEEZER_SONG::"
            case .soundcloud:
                return "SOUNDCLOUD_SONG::"
            case .appleMusic:
                return "ITUNES_SONG::"
            case .youtube, .youtubeMusic:
                return "YOUTUBE_VIDEO::"
            default:
                return ""
        }
    }
}

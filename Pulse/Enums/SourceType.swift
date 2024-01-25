//
//  SourceType.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import Foundation

enum SourceType: String {
    case muffon      = "muffon"
    case soundcloud  = "soundcloud"
    case none        = ""
    case yandexMusic = "yandexmusic"
    case pulse       = "pulse"
    
    static func soundcloudService(_ service: SoundcloudSourceType) -> SourceType {
        switch service {
            case .muffon:
                return .muffon
            case .soundcloud:
                return .soundcloud
            case .none:
                return .none
        }
    }
    
    static func yandexMusicService(_ service: YandexMusicSourceType) -> SourceType {
        switch service {
            case .muffon:
                return .muffon
            case .yandexMusic:
                return .yandexMusic
            case .none:
                return .none
        }
    }
    
    var soundcloudService: SoundcloudSourceType {
        return switch self {
            case .muffon:
                .muffon
            case .soundcloud:
                .soundcloud
            default:
                .none
        }
    }
    
    var yandexMusicService: YandexMusicSourceType {
        return switch self {
            case .muffon:
                .muffon
            case .yandexMusic:
                .yandexMusic
            default:
                .none
        }
    }
}

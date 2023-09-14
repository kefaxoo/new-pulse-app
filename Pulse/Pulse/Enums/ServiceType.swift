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
                return ""
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
        return [.soundcloud]
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
            default:
                return .none
        }
    }
    
    var image: UIImage? {
        switch self {
            case .soundcloud:
                return Constants.Images.soundcloudLogo.image
            default:
                return nil
        }
    }
    
    var source: SourceType {
        switch self {
            case .soundcloud:
                return .muffon
            default:
                return .none
        }
    }
}

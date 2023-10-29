//
//  SearchType.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import Foundation

enum SearchType {
    case tracks
    case albums
    case artists
    case none
    
    var muffonApi: String {
        switch self {
            case .tracks:
                return "tracks"
            case .albums:
                return "albums"
            case .artists:
                return "artists"
            case .none:
                return ""
        }
    }
    
    var soundcloudApi: String {
        switch self {
            case .tracks:
                return "tracks"
            case .albums:
                return ""
            case .artists:
                return "users"
            case .none:
                return ""
        }
    }
    
    static func types(for service: ServiceType) -> [SearchType] {
        switch service {
            case .vk:
                return []
            case .yandexMusic:
                return []
            case .spotify:
                return []
            case .deezer:
                return []
            case .soundcloud:
                return [.tracks]
            case .none:
                return []
        }
    }
    
    var title: String {
        switch self {
            case .tracks:
                return "Tracks"
            case .albums:
                return "Albums"
            case .artists:
                return "Artists"
            case .none:
                return ""
        }
    }
    
    var id: String {
        switch self {
            case .tracks:
                return TrackTableViewCell.id
            default:
                return ""
        }
    }
}

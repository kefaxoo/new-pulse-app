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
    case playlists
    case none
    
    var muffonApi: String {
        switch self {
            case .tracks:
                return "tracks"
            case .albums:
                return "albums"
            case .artists:
                return "artists"
            default:
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
            case .playlists:
                return "playlists"
            case .none:
                return ""
        }
    }
    
    var yandexMusicApi: String {
        switch self {
            case .tracks:
                return "track"
            case .albums:
                return "album"
            case .artists:
                return "artist"
            case .playlists:
                return "playlist"
            case .none:
                return ""
        }
    }
    
    static func types(for service: ServiceType) -> [SearchType] {
        switch service {
            case .yandexMusic:
                let types: [SearchType] = [.tracks]
                return types
            case .soundcloud:
                var soundcloudTypes: [SearchType] = [.tracks]
                if service.source == .soundcloud,
                   AppEnvironment.current.isDebug || SettingsManager.shared.localFeatures.searchSoundcloudPlaylists?.prod ?? false {
                    soundcloudTypes.append(.playlists)
                }
                
                return soundcloudTypes
            case .deezer:
                return [.tracks]
            default:
                return []
        }
    }
    
    var title: String {
        switch self {
            case .tracks:
                return Localization.Words.tracks.localization
            case .albums:
                return Localization.Words.albums.localization
            case .artists:
                return Localization.Words.artists.localization
            case .playlists:
                return Localization.Words.playlists.localization
            case .none:
                return ""
        }
    }
    
    var id: String {
        switch self {
            case .tracks:
                return TrackTableViewCell.id
            case .playlists:
                return PlaylistTableViewCell.id
            default:
                return ""
        }
    }
}

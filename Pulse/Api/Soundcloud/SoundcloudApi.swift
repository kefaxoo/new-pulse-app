//
//  SoundcloudApi.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import Foundation
import FriendlyURLSession

enum SoundcloudApi {
    // MARK: Authorization
    case signIn
    case refreshToken
    
    // MARK: User
    case userInfoWith(accessToken: String)
    
    // MARK: Library
    case likedTracks(cursor: String?)
    case likedPlaylists(cursor: String?)
    case userPlaylists(cursor: String?)
    
    // MARK: Track
    case trackInfo(id: String)
    case playableLink(id: String)
    case likeTrack(id: String)
    case removeLikeTrack(id: String)
    
    // MARK: Search
    case search(type: SearchType, query: String, offset: Int)
    
    // MARK: Playlist
    case playlistTracks(id: Int, offset: String?)
}

extension SoundcloudApi: BaseRestApiEnum {
    var baseUrl: String {
        return "https://api.soundcloud.com"
    }
    
    var path: String {
        switch self {
            case .signIn, .refreshToken:
                return "/oauth2/token"
            case .userInfoWith:
                return "/me"
            case .likedTracks:
                return "/me/likes/tracks"
            case .likedPlaylists:
                return "/me/likes/playlists"
            case .trackInfo(let id):
                return "/tracks/\(id)"
            case .playableLink(let id):
                return "/tracks/\(id)/streams"
            case .likeTrack(let id), .removeLikeTrack(let id):
                return "/likes/tracks/\(id)"
            case .search(let type, _, _):
                return "/\(type.soundcloudApi)"
            case .playlistTracks(let id, _):
                return "/playlists/\(id)/tracks"
            case .userPlaylists:
                return "/me/playlists"
        }
    }
    
    var method: FriendlyURLSession.HTTPMethod {
        switch self {
            case .signIn, .refreshToken, .likeTrack:
                return .post
            case .removeLikeTrack:
                return .delete
            default:
                return .get
        }
    }
    
    var headers: FriendlyURLSession.Headers? {
        var headers = Headers()
        switch self {
            case .signIn, .refreshToken:
                break
            case .userInfoWith(let accessToken):
                headers["Authorization"] = "Bearer \(accessToken)"
            default:
                headers["Authorization"] = "Bearer \(SettingsManager.shared.soundcloud.accessToken ?? "")"
        }
        return headers
    }
    
    var parameters: FriendlyURLSession.Parameters? {
        var parameters = Parameters()
        switch self {
            case .signIn:
                parameters["grant_type"]    = "authorization_code"
                parameters["client_id"]     = Constants.Soundcloud.clientId.rawValue
                parameters["client_secret"] = Constants.Soundcloud.clientSecret.rawValue
                parameters["redirect_uri"]  = Constants.Soundcloud.redirectLink.rawValue
                parameters["code"]          = SettingsManager.shared.soundcloud.signToken
            case .refreshToken:
                parameters["grant_type"]    = "refresh_token"
                parameters["client_id"]     = Constants.Soundcloud.clientId.rawValue
                parameters["client_secret"] = Constants.Soundcloud.clientSecret.rawValue
                parameters["redirect_uri"]  = Constants.Soundcloud.redirectLink.rawValue
                parameters["refresh_token"] = SettingsManager.shared.soundcloud.refreshToken ?? ""
            case .likedTracks(let cursor):
                parameters["limit"]               = 20
                parameters["access"]              = "playable"
                parameters["linked_partitioning"] = true
                guard let cursor else { break }
                
                parameters["cursor"] = cursor
            case .search(let type, let query, let offset):
                parameters["q"]                   = query
                parameters["access"]              = "playable"
                parameters["limit"]               = 20
                parameters["linked_partitioning"] = true
                parameters["offset"]              = offset
                if type == .playlists {
                    parameters["show_tracks"] = false
                }
                
            case .likedPlaylists(let cursor):
                parameters["limit"]               = 10
                parameters["linked_partitioning"] = true
                guard let cursor else { break }
                
                parameters["cursor"] = cursor
            case .playlistTracks(_, let offset):
                parameters["access"]              = "playable"
                parameters["linked_partitioning"] = true
                parameters["limit"]               = 20
                guard let offset else { break }
                
                parameters["offset"] = offset
            case .userPlaylists(let cursor):
                parameters["limit"]               = 20
                parameters["linked_partitioning"] = true
                parameters["show_tracks"]         = false
                guard let cursor else { break }
                
                parameters["cursor"] = cursor
            default:
                break
        }
        return parameters
    }
}

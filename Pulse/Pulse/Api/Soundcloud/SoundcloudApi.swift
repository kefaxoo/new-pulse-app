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
    case likedTracks
    
    // MARK: Track
    case trackInfo(id: Int)
    case playableLink(id: Int)
    case likeTrack(id: Int)
    
    // MARK: Search
    case search(type: SearchType, query: String)
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
            case .trackInfo(let id):
                return "/tracks/\(id)"
            case .playableLink(let id):
                return "/tracks/\(id)/streams"
            case .likeTrack(let id):
                return "/likes/tracks/\(id)"
            case .search(let type, _):
                return "/\(type.soundcloudApi)"
        }
    }
    
    var method: FriendlyURLSession.HTTPMethod {
        switch self {
            case .signIn, .refreshToken, .likeTrack:
                return .post
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
            case .likedTracks:
                parameters["limit"]               = 20
                parameters["access"]              = "playable"
                parameters["linked_partitioning"] = true
            case .search(_, let query):
                parameters["q"]                   = query
                parameters["access"]              = "playable"
                parameters["limit"]               = 20
                parameters["linked_partitioning"] = true
            default:
                break
        }
        return parameters
    }
}

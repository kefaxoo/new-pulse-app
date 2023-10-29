//
//  PulseApi.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import Foundation
import FriendlyURLSession

enum PulseApi {
    // User
    case createUser(credentials: Credentials)
    case loginUser(credentials: Credentials)
    case resetPassword(credentials: Credentials)
    case accessToken
    
    case createUserV2(credentials: Credentials)
    case loginUserV2(credentials: Credentials)
    case accessTokenV2
    
    // Covers
    case topCovers(country: String? = nil)
    
    // Log
    case log(log: [String: Any])
    
    // Library
    case syncTrack(_ track: TrackModel)
    case fetchTracks
    case removeTrack(_ track: TrackModel)

    // Soundcloud
    case soundcloudArtwork(link: String)
    case soundcloudPlaylistArtwork(id: String)
}

extension PulseApi: BaseRestApiEnum {
    var baseUrl: String {
        switch AppEnvironment.current {
            case .local:
                return "http://192.168.100.70:8000/api"
            case .test:
                return "https://test-pulse-api.fly.dev/api"
            default:
                return "https://prod-pulse-api.fly.dev/api"
        }
    }
    
    var path: String {
        switch self {
            case .createUser, .loginUser:
                return "/user"
            case .resetPassword:
                return "/user/resetPassword"
            case .accessToken:
                return "/user/accessToken"
            case .topCovers:
                return "/topCovers"
            case .log:
                return "/log"
            case .syncTrack, .removeTrack:
                return "/library/track"
            case .fetchTracks:
                return "/library/tracks"
            case .soundcloudArtwork:
                return "/soundcloud/artwork"
            case .soundcloudPlaylistArtwork:
                return "/soundcloud/playlist/artwork"
            case .createUserV2, .loginUserV2:
                return "/v2/user"
            case .accessTokenV2:
                return "/v2/user/accessToken"
        }
    }
    
    var method: FriendlyURLSession.HTTPMethod {
        switch self {
            case .createUser, .log, .syncTrack, .createUserV2:
                return .post
            case .removeTrack:
                return .delete
            default:
                return .get
        }
    }
    
    var headers: FriendlyURLSession.Headers? {
        var headers = Headers()
        headers["User-Agent"] = NetworkManager.shared.userAgent
        switch self {
            case .syncTrack, .fetchTracks, .removeTrack, .soundcloudArtwork:
                guard let accessToken = SettingsManager.shared.pulse.accessToken else { break }
                
                headers["Authorization"] = "Bearer \(accessToken)"
            case .soundcloudPlaylistArtwork:
                if let accessToken = SettingsManager.shared.pulse.accessToken {
                    headers["Authorization"] = "Bearer \(accessToken)"
                }
                
                if let soundcloudToken = SettingsManager.shared.soundcloud.accessToken {
                    headers["X-Soundcloud-Token"] = soundcloudToken
                }
            case .accessTokenV2:
                if let refreshToken = SettingsManager.shared.pulse.refreshToken {
                    headers["X-Pulse-Refresh-Token"] = refreshToken
                }
            default:
                break
        }
        
        return headers
    }
    
    var parameters: FriendlyURLSession.Parameters? {
        var parameters = Parameters()
        switch self {
            case .createUser(let credentials), .loginUser(let credentials), .resetPassword(let credentials), .createUserV2(let credentials), 
                    .loginUserV2(let credentials):
                parameters["email"]    = credentials.username
                parameters["password"] = credentials.password
            case .accessToken:
                parameters["email"]    = SettingsManager.shared.pulse.username
                parameters["password"] = SettingsManager.shared.pulse.password ?? ""
            case .topCovers(let country):
                parameters["country"] = country
            case .removeTrack(let track):
                parameters["track_id"] = String(track.id)
                parameters["service"]  = track.service.rawValue
                parameters["source"]   = track.source.rawValue
            case .soundcloudArtwork(let link):
                parameters["artwork_link"] = link
            case .soundcloudPlaylistArtwork(let id):
                parameters["playlist_id"] = id
            default:
                return nil
        }
        
        return parameters
    }
    
    var body: JSON? {
        switch self {
            case .log(let log):
                return log
            case .syncTrack(let track):
                return track.json
            default:
                return nil
        }
    }
}

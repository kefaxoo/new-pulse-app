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
    
    // User V2
    case createUserV2(credentials: Credentials)
    case loginUserV2(credentials: Credentials)
    case resetPasswordV2(credentials: Credentials)
    case accessTokenV2
    
    // User V3
    case createUserV3(credentials: Credentials, signMethod: SignMethodType)
    case externalSign(email: String, signMethod: SignMethodType)
    case loginUserV3(credentials: Credentials, signMethod: SignMethodType)
    case resetPasswordV3(credentials: Credentials)
    case accessTokenV3
    
    // Covers
    case topCovers(country: String? = nil)
    
    // Log
    case log(log: [String: Any])
    
    // Library
    case syncTrack(_ track: TrackModel)
    case fetchTracks
    case removeTrack(_ track: TrackModel)
    
    // Library V2
    case syncTracks
    case likeTrack(_ track: TrackModel)
    case dislikeTrack(_ track: TrackModel)
    case incrementListenCount(_ track: TrackModel)
    case fetchDislikedTracks(offset: Int)

    // Soundcloud
    case soundcloudArtwork(link: String)
    case soundcloudPlaylistArtwork(id: String)
    
    // Soundcloud V2
    case soundcloudArtworkV2(link: String)
    case soundcloudPlaylistArtworkV2(id: String)
    
    case features
}

extension PulseApi: BaseRestApiEnum {
    var baseUrl: String {
        switch AppEnvironment.current {
            case .local:
                return "\(Constants.localPulseBaseUrl)/api"
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
            case .features:
                return "/features"
            case .resetPasswordV2:
                return "/v2/user/resetPassword"
            case .createUserV3, .loginUserV3:
                return "/v3/user"
            case .externalSign:
                return "/v3/user/external"
            case .resetPasswordV3:
                return "/v3/user/resetPassword"
            case .accessTokenV3:
                return "/v3/user/accessToken"
            case .syncTracks:
                return "/v2/library/tracks/sync"
            case .likeTrack, .dislikeTrack:
                return "/v2/library/track"
            case .incrementListenCount:
                return "/v2/library/track/incrementListenCount"
            case .fetchDislikedTracks:
                return "/v2/library/tracks/disliked"
            case .soundcloudPlaylistArtworkV2:
                return "/v2/soundcloud/playlist/artwork"
            case .soundcloudArtworkV2:
                return "/v2/soundcloud/artwork"
        }
    }
    
    var method: FriendlyURLSession.HTTPMethod {
        switch self {
            case .createUser, .log, .syncTrack, .createUserV2, .features, .createUserV3, .externalSign, .syncTracks, .likeTrack, 
                    .incrementListenCount:
                return .post
            case .removeTrack, .dislikeTrack:
                return .delete
            case .resetPasswordV3:
                return .patch
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
            case .accessTokenV2, .accessTokenV3:
                if let refreshToken = SettingsManager.shared.pulse.refreshToken {
                    headers["X-Pulse-Refresh-Token"] = refreshToken
                }
            case .syncTracks, .likeTrack, .dislikeTrack, .incrementListenCount, .fetchDislikedTracks, .soundcloudArtworkV2:
                if let accessToken = SettingsManager.shared.pulse.accessToken {
                    headers["X-Pulse-Token"] = accessToken
                }
            case .soundcloudPlaylistArtworkV2:
                if let accessToken = SettingsManager.shared.pulse.accessToken {
                    headers["X-Pulse-Token"] = accessToken
                }
                
                if let soundcloudToken = SettingsManager.shared.soundcloud.accessToken {
                    headers["X-Soundcloud-Token"] = soundcloudToken
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
                    .loginUserV2(let credentials), .resetPasswordV2(let credentials), .resetPasswordV3(let credentials):
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
            case .soundcloudArtwork(let link), .soundcloudArtworkV2(let link):
                parameters["artwork_link"] = link
            case .soundcloudPlaylistArtwork(let id), .soundcloudPlaylistArtworkV2(let id):
                parameters["playlist_id"] = id
            case .createUserV3(let credentials, let signMethod), .loginUserV3(let credentials, let signMethod):
                parameters["email"]        = credentials.username
                parameters["account_type"] = signMethod.rawValue
                parameters["password"]     = credentials.password
            case .externalSign(let email, let signMethod):
                parameters["email"]        = email
                parameters["account_type"] = signMethod.rawValue
            case .dislikeTrack(let track):
                parameters["track_id"] = track.id
                parameters["service"]  = track.service.rawValue
                parameters["source"]   = track.source.rawValue
            case .fetchDislikedTracks(let offset):
                parameters["offset"] = offset
                parameters["limit"]  = 20
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
            case .features:
                return ["features": SettingsManager.shared.featuresKeys]
            case .syncTracks:
                return ["tracks": RealmManager<LibraryTrackModel>().read().compactMap({ TrackModel($0).newJson })]
            case .likeTrack(let track), .incrementListenCount(let track):
                return track.newJson
            default:
                return nil
        }
    }
}

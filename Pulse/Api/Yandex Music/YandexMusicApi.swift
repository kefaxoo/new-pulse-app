//
//  YandexMusicApi.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 14.12.23.
//

import Foundation
import FriendlyURLSession

enum YandexMusicApi {
    // MARK: - Account
    case userProfileInfo
    case accountInfo
    
    // MARK: - Search
    case search(query: String, page: Int, type: SearchType)
    
    // MARK: - Audio link
    case fetchAudioLinkStep1(trackId: Int)
    case fetchAudioLinkStep2(components: URLComponents)
    
    // MARK: - Media
    case track(trackId: Int)
    case likeTrack(track: TrackModel)
    case removeLikeTrack(track: TrackModel)
}

extension YandexMusicApi: BaseRestApiEnum {
    var baseUrl: String {
        switch self {
            case .userProfileInfo:
                return "https://login.yandex.ru"
            case .fetchAudioLinkStep2(let components):
                return components.fullHost ?? ""
            default:
                return "https://api.music.yandex.net"
        }
    }
    
    var path: String {
        switch self {
            case .userProfileInfo:
                return "/info"
            case .accountInfo:
                return "/account/status"
            case .search:
                return "/search"
            case .fetchAudioLinkStep1(let id):
                return "/tracks/\(id)/download-info"
            case .fetchAudioLinkStep2(let components):
                return components.path
            case .track(let trackId):
                return "/tracks/\(trackId)"
            case .likeTrack:
                return "/users/\(SettingsManager.shared.yandexMusic.id)/likes/tracks/add-multiple"
            case .removeLikeTrack:
                return "/users/\(SettingsManager.shared.yandexMusic.id)/likes/tracks/remove"
        }
    }
    
    var method: FriendlyURLSession.HTTPMethod {
        switch self {
            case .likeTrack, .removeLikeTrack:
                return .post
            default:
                return .get
        }
    }
    
    var headers: FriendlyURLSession.Headers? {
        var headers = Headers()
        if let accessToken = SettingsManager.shared.yandexMusic.accessToken {
            headers["Authorization"] = "OAuth \(accessToken)"
        }
        
        return headers
    }
    
    var parameters: FriendlyURLSession.Parameters? {
        var parameters = Parameters()
        switch self {
            case .userProfileInfo:
                parameters["format"] = "json"
            case .search(let query, let page, let type):
                parameters["text"] = query
                parameters["page"] = page
                parameters["type"] = type.yandexMusicApi
            case .fetchAudioLinkStep2(let components):
                parameters["format"] = "json"
                components.queryItems?.forEach({ parameters[$0.name] = $0.value })
            default:
                break
        }
        
        return parameters
    }
    
    var body: JSON? {
        var body = JSON()
        switch self {
            case .likeTrack(let track), .removeLikeTrack(let track):
                if let artistId = track.artist?.id {
                    body["track-ids"] = "\(track.id):\(artistId)"
                }
            default:
                return nil
        }
        
        return body
    }
    
    var bodyType: BodyType? {
        switch self {
            case .likeTrack, .removeLikeTrack:
                return .urlEncoded
            default:
                return nil
        }
    }
}

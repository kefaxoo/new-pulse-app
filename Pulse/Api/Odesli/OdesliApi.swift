//
//  OdesliApi.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.12.23.
//

import Foundation
import FriendlyURLSession

enum OdesliApi {
    case songLinks(track: TrackModel)
}

extension OdesliApi: BaseRestApiEnum {
    var baseUrl: String {
        return "https://api.song.link/v1-alpha.1"
    }
    
    var path: String {
        switch self {
            case .songLinks:
                return "/links"
        }
    }
    
    var method: FriendlyURLSession.HTTPMethod {
        switch self {
            case .songLinks:
                return .get
        }
    }
    
    var headers: FriendlyURLSession.Headers? {
        return nil
    }
    
    var parameters: FriendlyURLSession.Parameters? {
        var params = Parameters()
        switch self {
            case .songLinks(let track):
                params["key"]      = "9ab8abaf-c5f1-4edb-8e7f-7f72c7033693"
                params["type"]     = "song"
                if track.service != .pulse {
                    params["id"]       = track.id
                    params["platform"] = track.service.odesliApi
                } else {
                    if let spotifyId = track.spotifyId {
                        params["id"]       = spotifyId
                        params["platform"] = ServiceType.spotify.odesliApi
                    } else if let yandexMusicId = track.yandexMusicId {
                        params["id"]       = yandexMusicId
                        params["platform"] = ServiceType.yandexMusic.odesliApi
                    }
                }
        }
        return params
    }
}

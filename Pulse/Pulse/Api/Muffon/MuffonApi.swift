//
//  MuffonApi.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import Foundation
import FriendlyURLSession

enum MuffonApi {
    case search(type: SearchType, service: ServiceType, query: String)
    case trackInfo(_ track: TrackModel)
}

extension MuffonApi: BaseRestApiEnum {
    var baseUrl: String {
        return "https://178-79-138-81.ip.linodeusercontent.com/api"
    }
    
    var path: String {
        switch self {
            case .search(let type, let service, _):
                return "/\(service.muffonApi)/search/\(type.muffonApi)"
            case .trackInfo(let track):
                return "/\(track.service.muffonApi)/tracks/\(track.id)/"
        }
    }
    
    var method: FriendlyURLSession.HTTPMethod {
        return .get
    }
    
    var headers: FriendlyURLSession.Headers? {
        return nil
    }
    
    var parameters: FriendlyURLSession.Parameters? {
        var parameters = Parameters()
        parameters["token"] = "1b80e13d-b306-4223-b0a7-cf9013bda6cf"
        switch self {
            case .search(_, _, let query):
                parameters["query"] = query
            default:
                break
        }
        
        return parameters
    }
}

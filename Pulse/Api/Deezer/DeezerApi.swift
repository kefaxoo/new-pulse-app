//
//  DeezerApi.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 18.02.24.
//

import Foundation
import FriendlyURLSession

enum DeezerApi {
    case artist(artistId: Int)
}

extension DeezerApi: BaseRestApiEnum {
    var baseUrl: String {
        return "https://api.deezer.com"
    }
    
    var path: String {
        switch self {
            case .artist(let artistId):
                return "/artist/\(artistId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
            default:
                return .get
        }
    }
    
    var headers: FriendlyURLSession.Headers? {
        return nil
    }
    
    var parameters: FriendlyURLSession.Parameters? {
        return nil
    }
}

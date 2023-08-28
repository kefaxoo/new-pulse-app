//
//  ipifyApi.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import Foundation
import FriendlyURLSession

enum ipifyApi {
    case getIp
}

extension ipifyApi: BaseRestApiEnum {
    var baseUrl: String {
        return "https://api.ipify.org"
    }
    
    var path: String {
        return ""
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: Headers? {
        return nil
    }
    
    var parameters: Parameters? {
        return ["format": "json"]
    }
}

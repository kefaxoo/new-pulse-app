//
//  PulseApi.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import Foundation
import FriendlyURLSession

enum PulseApi {
    case topCovers(country: String? = nil)
}

extension PulseApi: BaseRestApiEnum {
    var baseUrl: String {
        return "https://test-pulse-api.fly.dev/api"
    }
    
    var path: String {
        switch self {
            case .topCovers:
                return "/topCovers"
        }
    }
    
    var method: FriendlyURLSession.HTTPMethod {
        switch self {
            case .topCovers:
                return .get
        }
    }
    
    var headers: FriendlyURLSession.Headers? {
        var headers = Headers()
        headers["User-Agent"] = NetworkManager.shared.userAgent
        return headers
    }
    
    var parameters: FriendlyURLSession.Parameters? {
        var parameters = Parameters()
        switch self {
            case .topCovers(let country):
                parameters["country"] = "US"
        }
        
        return parameters
    }
}

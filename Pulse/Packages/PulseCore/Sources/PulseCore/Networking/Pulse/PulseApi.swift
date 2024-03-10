//
//  PulseApi.swift
//
//
//  Created by Bahdan Piatrouski on 9.03.24.
//

import Foundation
import FriendlyURLSession

enum PulseApi {
    // MARK: - Device
    case deviceInfo
}

extension PulseApi: BaseRestApiEnum {
    var baseUrl: String {
        switch AppEnvironment.current {
            case .test:
                return "https://test-pulse-api.fly.dev/api"
            case .releaseProd, .releaseDebug:
                return "https://prod-pulse-api.fly.dev/api"
            default:
                return ""
        }
    }
    
    var path: String {
        switch self {
            case .deviceInfo:
                return "/device/info"
        }
    }
    
    var method: FriendlyURLSession.HTTPMethod {
        switch self {
            default:
                return .get
        }
    }
    
    var headers: FriendlyURLSession.Headers? {
        var headers = Headers()
        headers["User-Agent"] = NetworkManager.userAgent
        
        return headers
    }
    
    var parameters: FriendlyURLSession.Parameters? {
        var parameters = Parameters()
        return parameters
    }
}

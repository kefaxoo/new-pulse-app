//
//  IpApi.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import Foundation
import FriendlyURLSession

enum IpApi {
    case getCountry
}

extension IpApi: BaseRestApiEnum {
    var baseUrl: String {
        return "http://ip-api.com"
    }
    
    var path: String {
        return "/json/\(NetworkManager.shared.ip)"
    }
    
    var method: FriendlyURLSession.HTTPMethod {
        return .get
    }
    
    var headers: FriendlyURLSession.Headers? {
        return nil
    }
    
    var parameters: FriendlyURLSession.Parameters? {
        return nil
    }
}

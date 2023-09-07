//
//  VkApi.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 5.09.23.
//

import Foundation
import FriendlyURLSession

enum VkApi {
    case auth(credentials: Credentials)
}

extension VkApi: BaseRestApiEnum {
    var baseUrl: String {
        switch self {
            case .auth:
                return "https://oauth.vk.com"
        }
    }
    
    var path: String {
        switch self {
            case .auth:
                return "/token"
        }
    }
    
    var method: FriendlyURLSession.HTTPMethod {
        switch self {
            case .auth:
                return .get
        }
    }
    
    var headers: FriendlyURLSession.Headers? {
        var headers = Headers()
        return headers
    }
    
    var parameters: FriendlyURLSession.Parameters? {
        var parameters = Parameters()
        switch self {
            case .auth(let credentials):
                parameters["grant_type"]    = "password"
                parameters["client_id"]     = 2274003
                parameters["client_secret"] = "hHbZxrka2uZ6jB1inYsH"
                parameters["username"]      = credentials.username
                parameters["password"]      = credentials.password
                parameters["lang"]          = "en"
                parameters["scope"]         = "all"
                parameters["device_id"]     = String(length: 16, symbols: "0123456789abcdef")
        }
        
        return parameters
    }
}

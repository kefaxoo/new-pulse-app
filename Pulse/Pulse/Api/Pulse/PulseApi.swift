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
    
    // Covers
    case topCovers(country: String? = nil)
    
    // Log
    case log(log: [String: Any])
}

extension PulseApi: BaseRestApiEnum {
    var baseUrl: String {
        return "https://test-pulse-api.fly.dev/api"
    }
    
    var path: String {
        switch self {
            case .createUser, .loginUser:
                return "/user"
            case .resetPassword:
                return "/user/resetPassword"
            case .topCovers:
                return "/topCovers"
            case .log:
                return "/log"
        }
    }
    
    var method: FriendlyURLSession.HTTPMethod {
        switch self {
            case .createUser, .log:
                return .post
            default:
                return .get
        }
    }
    
    var headers: FriendlyURLSession.Headers? {
        var headers = Headers()
        headers["User-Agent"] = NetworkManager.shared.userAgent
        switch self {
            case .log:
                guard let accessToken = SettingsManager.shared.pulse.accessToken else { break }
                
                headers["Authorization"] = accessToken
            default:
                break
        }
        
        return headers
    }
    
    var parameters: FriendlyURLSession.Parameters? {
        var parameters = Parameters()
        switch self {
            case .createUser(let credentials), .loginUser(let credentials), .resetPassword(let credentials):
                parameters["email"] = credentials.username
                parameters["password"] = credentials.password
            case .topCovers(let country):
                parameters["country"] = country
            default:
                return nil
        }
        
        return parameters
    }
    
    var body: JSON? {
        switch self {
            case .log(let log):
                return log
            default:
                return nil
        }
    }
}

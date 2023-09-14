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
    case accessToken
    
    // Covers
    case topCovers(country: String? = nil)
    
    // Log
    case log(log: [String: Any])
    
    // Library
    case addTrackToLibrary(_ track: TrackModel)
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
            case .accessToken:
                return "/user/accessToken"
            case .topCovers:
                return "/topCovers"
            case .log:
                return "/log"
            case .addTrackToLibrary:
                return "/library/track"
                
        }
    }
    
    var method: FriendlyURLSession.HTTPMethod {
        switch self {
            case .createUser, .log, .addTrackToLibrary:
                return .post
            default:
                return .get
        }
    }
    
    var headers: FriendlyURLSession.Headers? {
        var headers = Headers()
        headers["User-Agent"] = NetworkManager.shared.userAgent
        switch self {
            case .log, .addTrackToLibrary:
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
                parameters["email"]    = credentials.username
                parameters["password"] = credentials.password
            case .accessToken:
                parameters["email"]    = SettingsManager.shared.pulse.username
                parameters["password"] = SettingsManager.shared.pulse.password ?? ""
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
            case .addTrackToLibrary(let track):
                return nil
            default:
                return nil
        }
    }
}

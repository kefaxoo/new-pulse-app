//
//  SoundcloudApi.swift
//
//
//  Created by Bahdan Piatrouski on 11.03.24.
//

import Foundation
import FriendlyURLSession

enum SoundcloudApi: Equatable {
    // MARK: - OAuth
    case signIn
    case refreshToken
    
    // MARK: - User
    case userInfoWith(accessToken: String)
}

extension SoundcloudApi: BaseRestApiEnum {
    var baseUrl: String {
        return "https://api.soundcloud.com"
    }
    
    var path: String {
        switch self {
            case .signIn, .refreshToken:
                return "/oauth2/token"
            case .userInfoWith:
                return "/me"
        }
    }
    
    var method: FriendlyURLSession.HTTPMethod {
        switch self {
            case .signIn, .refreshToken:
                return .post
            default:
                return .get
        }
    }
    
    var headers: FriendlyURLSession.Headers? {
        var headers = Headers()
        switch self {
            case .signIn, .refreshToken:
                break
            case .userInfoWith(let accessToken):
                headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        return headers
    }
    
    var parameters: FriendlyURLSession.Parameters? {
        var parameters = Parameters()
        switch self {
            case .signIn, .refreshToken:
                parameters["grant_type"] = self == .signIn ? "authorization_code" : "refresh_token"
                parameters["client_id"] = "5acc74891941cfc73ec8ee2504be6617"
                parameters["client_secret"] = "ca2b69301bd1f73985a9b47224a2a239"
                parameters["redirect_uri"] = "https://quodlibet.github.io/callbacks/soundcloud.html"
                if self == .signIn {
                    parameters["code"] = SettingsManager.shared.soundcloud.signToken
                } else if let refreshToken = SettingsManager.shared.soundcloud.refreshToken {
                    parameters["refresh_token"] = refreshToken
                }
            default:
                break
        }
        
        return parameters
    }
}

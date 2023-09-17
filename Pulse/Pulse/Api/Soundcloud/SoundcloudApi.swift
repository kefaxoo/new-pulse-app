//
//  SoundcloudApi.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import Foundation
import FriendlyURLSession

enum SoundcloudApi {
    // MARK: Authorization
    case signIn
    case refreshToken
    
    // MARK: User
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
            case .userInfoWith(let accessToken):
                headers["Authorization"] = "Bearer \(accessToken)"
            default:
                break
        }
        return headers
    }
    
    var parameters: FriendlyURLSession.Parameters? {
        var parameters = Parameters()
        switch self {
            case .signIn:
                parameters["grant_type"]    = "authorization_code"
                parameters["client_id"]     = Constants.Soundcloud.clientId.rawValue
                parameters["client_secret"] = Constants.Soundcloud.clientSecret.rawValue
                parameters["redirect_uri"]  = Constants.Soundcloud.redirectLink.rawValue
                parameters["code"]          = SettingsManager.shared.soundcloud.signToken
            case .refreshToken:
                parameters["grant_type"]    = "refresh_token"
                parameters["client_id"]     = Constants.Soundcloud.clientId.rawValue
                parameters["client_secret"] = Constants.Soundcloud.clientSecret.rawValue
                parameters["redirect_uri"]  = Constants.Soundcloud.redirectLink.rawValue
                parameters["refresh_token"] = SettingsManager.shared.soundcloud.refreshToken ?? ""
            default:
                break
        }
        return parameters
    }
}

//
//  YandexMusicApi.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 14.12.23.
//

import Foundation
import FriendlyURLSession

enum YandexMusicApi {
    // MARK: - Account
    case userProfileInfo
    case accountInfo
extension YandexMusicApi: BaseRestApiEnum {
    var baseUrl: String {
        switch self {
            case .userProfileInfo:
                return "https://login.yandex.ru"
            default:
                return "https://api.music.yandex.net"
        }
    }
    
    var path: String {
        switch self {
            case .userProfileInfo:
                return "/info"
            case .accountInfo:
                return "/account/status"
    
    var method: FriendlyURLSession.HTTPMethod {
        switch self {
            default:
                return .get
        }
    }
    
    var headers: FriendlyURLSession.Headers? {
        var headers = Headers()
        if let accessToken = SettingsManager.shared.yandexMusic.accessToken {
            headers["Authorization"] = "OAuth \(accessToken)"
        }
        
        return headers
    }
    
    var parameters: FriendlyURLSession.Parameters? {
        var parameters = Parameters()
        switch self {
            case .userProfileInfo:
                parameters["format"] = "json"
            default:
                break
        }
        
        return parameters
    }
        }
    }
}

//
//  WebViewType.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import Foundation

enum WebViewType {
    case soundcloud
    case yandexMusic
    case none
    
    var initialLink: String {
        switch self {
            case .soundcloud:
                return "https://api.soundcloud.com/connect?client_id=5acc74891941cfc73ec8ee2504be6617&redirect_uri=https://quodlibet.github.io/callbacks/soundcloud.html&response_type=code"
            case .yandexMusic:
                return "https://oauth.yandex.ru/authorize?response_type=token&client_id=23cabbbdc6cd418abb4b39c32c41195d"
            case .none:
                return ""
        }
    }
    
    var obserableLink: String {
        switch self {
            case .soundcloud:
                return "https://quodlibet.github.io/callbacks/soundcloud.html?code="
            case .yandexMusic:
                return "https://music.yandex.ru/#access_token="
            case .none:
                return ""
        }
    }
    
    var replaceObservableLinkWith: String {
        switch self {
            default:
                return ""
        }
    }
    
    var shouldUseURLComponents: Bool {
        switch self {
            case .yandexMusic:
                return true
            default:
                return false
        }
    }
    
    var urlQueryComponent: String {
        switch self {
            case .yandexMusic:
                return "access_token"
            default:
                return ""
        }
    }
    
    // swiftlint:disable line_length
    var configureUserAgent: String {
        switch self {
            case .soundcloud:
                return "Mozilla/5.0 (iPhone; CPU iPhone OS 16_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.3 Mobile/15E148 Safari/604.1"
            default:
                return ""
        }
    }
    // swiftlint:enable line_length
    
    func saveSignToken(_ token: String) {
        switch self {
            case .soundcloud:
                SettingsManager.shared.soundcloud.signToken = token
            case .yandexMusic:
                SettingsManager.shared.yandexMusic.saveToken(token)
            default:
                return
        }
    }
}

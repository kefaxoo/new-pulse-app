//
//  LibraryControllerType.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 10.09.23.
//

import Foundation

enum LibraryControllerType {
    case library
    case soundcloud
    case yandexMusic
    case none
    case pulse
    
    var title: String {
        switch self {
            case .library:
                return Localization.Words.library.localization
            case .soundcloud:
                return "Soundcloud"
            case .yandexMusic:
                return Localization.Words.yandexMusic.localization
            case .none:
                return ""
            case .pulse:
                return "Pulse"
        }
    }
    
    var service: ServiceType {
        switch self {
            case .soundcloud:
                return .soundcloud
            case .yandexMusic:
                return .yandexMusic
            case .pulse:
                return .pulse
            default:
                return .none
        }
    }
}

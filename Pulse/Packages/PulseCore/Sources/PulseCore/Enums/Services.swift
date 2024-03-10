//
//  Services.swift
//
//
//  Created by Bahdan Piatrouski on 10.03.24.
//

import Foundation

public enum Services: String {
    case soundcloud
    case none = ""
    
    public var muffonApi: String {
        switch self {
            case .soundcloud:
                return self.rawValue
            case .none:
                return ""
        }
    }
    
    public var title: String {
        switch self {
            case .soundcloud:
                return "Soundcloud"
            case .none:
                return ""
        }
    }
    
    public static func fromMuffon(_ rawValue: String) -> Services {
        switch rawValue {
            case "soundcloud":
                return .soundcloud
            default:
                return .none
        }
    }
    
    public var odesliApi: String {
        switch self {
            case .soundcloud:
                return self.rawValue
            case .none:
                return ""
        }
    }
    
    public var odesliReplacePart: String {
        switch self {
            case .soundcloud:
                return "SOUNDCLOUD_SONG::"
            case .none:
                return ""
        }
    }
    
    public var isHistoryAvailable: Bool {
        switch self {
            case .soundcloud, .none:
                return false
        }
    }
    
    public static var searchController: [Services] {
        var services: [Services] = [.soundcloud]
        return services
    }
}

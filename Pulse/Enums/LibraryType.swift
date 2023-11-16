//
//  LibraryType.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 10.09.23.
//

import UIKit

enum LibraryType {
    case playlists
    case tracks
    case soundcloud
    
    var title: String {
        switch self {
            case .playlists:
                return "Playlists"
            case .tracks:
                return "Tracks"
            case .soundcloud:
                return "Soundcloud"
        }
    }
    
    var image: UIImage? {
        switch self {
            case .playlists:
                return Constants.Images.playlists.image
            case .tracks:
                return Constants.Images.tracks.image
            case .soundcloud:
                return Constants.Images.soundcloudLogo.image
        }
    }
    
    static func allCases(by service: ServiceType) -> [LibraryType] {
        var types = [LibraryType]()
        switch service {
            case .soundcloud:
                types.append(.playlists)
                types.append(.tracks)
            case .none:
                types.append(.tracks)
                if SettingsManager.shared.soundcloud.isSigned {
                    types.append(.soundcloud)
                }
            default:
                break
        }
        
        return types
    }
    
    func controllerType(service: ServiceType) -> LibraryControllerType {
        switch self {
            case .tracks:
                switch service {
                    case .soundcloud:
                        return .soundcloud
                    case .none:
                        return .library
                    default:
                        return .none
                }
            case .playlists:
                switch service {
                    case .soundcloud:
                        return .soundcloud
                    default:
                        return .none
                }
            case .soundcloud:
                return .soundcloud
        }
    }
    
    var service: ServiceType {
        switch self {
            case .playlists:
                return .none
            case .tracks:
                return .none
            case .soundcloud:
                return .soundcloud
        }
    }
}

//
//  SourceType.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import Foundation

enum SourceType: String {
    case muffon     = "muffon"
    case soundcloud = "soundcloud"
    case none       = ""
    
    static func soundcloudService(_ service: SoundcloudSourceType) -> SourceType {
        switch service {
            case .muffon:
                return .muffon
            case .soundcloud:
                return .soundcloud
            case .none:
                return .none
        }
    }
}

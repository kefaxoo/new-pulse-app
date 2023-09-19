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
    case none
    
    var title: String {
        switch self {
            case .library:
                return "Library"
            case .soundcloud:
                return "Soundcloud"
            case .none:
                return ""
        }
    }
}

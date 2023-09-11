//
//  LibraryType.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 10.09.23.
//

import UIKit

enum LibraryType: CaseIterable {
    case tracks
    
    var title: String {
        switch self {
            case .tracks:
                return "Tracks"
        }
    }
    
    var image: UIImage? {
        switch self {
            case .tracks:
                return UIImage(systemName: Constants.Images.System.musicNote)
        }
    }
    
    var controllerType: LibraryControllerType {
        switch self {
            case .tracks:
                return .library
        }
    }
}

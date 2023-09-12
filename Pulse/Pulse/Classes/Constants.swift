//
//  Constants.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import UIKit

enum ConstantsEnum {
    enum Images {
        case warning
        
        var image: UIImage? {
            switch self {
                case .warning:
                    return System.warning.image
            }
        }
    }
}

extension ConstantsEnum.Images {
    fileprivate enum System: String {
        case warning = "exclamationmark.triangle"
        
        var image: UIImage? {
            return UIImage(systemName: self.rawValue)
        }
    }
}

final class Constants {
    final class UserDefaultsKey {
        // Network Manager
        static let ip      = "deviceIp"
        static let country = "deviceCountry"
        
        // Pulse
        static let pulseUsername = "pulseUsername"
        
        // Color
        static let colorType = "accentColorType"
        
        // MARK: Settings
        // General settings
        static let isAdultContentEnabled = "general.isAdultContentEnabled"
        static let isCanvasesEnabled     = "general.isCanvasesEnabled"
        static let autoDownload          = "general.autoDownload"
    }
    
    static var isDebug: Bool {
#if DEBUG
        return true
#else
        return false
#endif
    }
    
    final class KeychainService {
        static let pulseCredentials = "pulseCredentials"
        static let pulseToken       = "pulseToken"
    }
    
    final class Images {
        final class System {
            static let appleLogo            = "apple.logo"
            static let exclamationMark      = "exclamationmark.triangle"
            static let eye                  = "eye"
            static let eyeWithSlash         = "eye.slash"
            static let xInFilledCircle      = "x.circle.fill"
            static let eInFilledSquare      = "e.square.fill"
            static let playFilled           = "play.fill"
            static let forwardFilled        = "forward.fill"
            static let gear                 = "gear"
            static let chevronRight         = "chevron.right"
            static let magnifyingGlass      = "magnifyingglass"
            static let ellipsis             = "ellipsis"
            static let pauseFilled          = "pause.fill"
            static let heart                = "heart"
            static let heartFilled          = "heart.fill"
            static let heartWithSlashFilled = "heart.slash.fill"
            static let share                = "square.and.arrow.up"
            static let musicNote            = "music.note"
            static let download             = "square.and.arrow.down"
            static let warning              = "exclamationmark.triangle"
        }
        
        final class Custom {
            static let soundcloudLogo = "SoundcloudLogo"
        }
    }
    
    final class RegularExpressions {
        static let pulsePassword = "(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}"
    }
}

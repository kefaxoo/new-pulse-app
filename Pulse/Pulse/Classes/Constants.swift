//
//  Constants.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import Foundation

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
            static let appleLogo       = "apple.logo"
            static let exclamationMark = "exclamationmark.triangle"
            static let eye             = "eye"
            static let eyeWithSlash    = "eye.slash"
            static let xInFilledCircle = "x.circle.fill"
            static let eInFilledSquare = "e.square.fill"
            static let playFilled      = "play.fill"
            static let forwardFilled   = "forward.fill"
            static let gear            = "gear"
            static let chevronRight    = "chevron.right"
        }
        
        final class Custom {
            static let vkMusicLogo = "VkMusicLogo"
        }
    }
    
    final class RegularExpressions {
        static let pulsePassword = "(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}"
    }
}

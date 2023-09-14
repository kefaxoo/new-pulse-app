//
//  Constants.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import UIKit

enum Constants {
    enum Images {
        case warning
        case inLibrary
        case downloaded
        case removeBin
        case playNext
        case playLast
        case dismissNowPlaying
        case removeFromLibrary
        case chevronRight
        case explicit
        case actions
        case play
        case pause
        case download
        case share
        case appleLogo
        case dismiss
        case eye
        case crossedEye
        case soundcloudLogo
        case settings
        case search
        case libraryNonSelected
        case librarySelected
        case tracks
        case nextTrack
        
        var image: UIImage? {
            let type: System
            switch self {
                case .warning:
                    type = .exclamationMarkTriangle
                case .inLibrary, .librarySelected:
                    type = .heartFill
                case .downloaded:
                    type = .arrowDownHeartFill
                case .removeBin:
                    type = .trashFill
                case .playNext:
                    type = .textInsert
                case .playLast:
                    type = .textAppend
                case .dismissNowPlaying:
                    type = .minus
                case .removeFromLibrary:
                    type = .heartSlashFill
                case .chevronRight:
                    type = .chevronRight
                case .explicit:
                    type = .eSquareFill
                case .actions:
                    type = .ellipsis
                case .play:
                    type = .playFill
                case .pause:
                    type = .pauseFill
                case .download:
                    type = .squareAndArrowDown
                case .share:
                    type = .squareAndArrowUp
                case .appleLogo:
                    type = .appleLogo
                case .dismiss:
                    type = .xCircleFill
                case .eye:
                    type = .eye
                case .crossedEye:
                    type = .eyeSlash
                case .settings:
                    type = .gear
                case .search:
                    type = .magnifyingGlass
                case .libraryNonSelected:
                    type = .heart
                case .tracks:
                    type = .musicNote
                case .nextTrack:
                    type = .forwardFill
                default:
                    return self.customImage
            }
            
            return type.image
        }
        
        fileprivate var customImage: UIImage? {
            let type: Custom
            switch self {
                case .soundcloudLogo:
                    type = .soundcloudLogo
                default:
                    return nil
            }
            
            return type.image
        }
    }
    
    // swiftlint:disable redundant_string_enum_value
    enum KeychainService: String {
        case pulseCredentials = "pulseCredentials"
        case pulseToken       = "pulseToken"
    }
    
    enum UserDefaultsKeys: String {
        case pulseUsername = "pulseUsername"
        case pulseExpireAt = "pulseExpireAt"
        
        case autoDownload          = "general.autoDownload"
        case isAdultContentEnabled = "general.isAdultContentEnabled"
        case isCanvasesEnabled     = "general.isCanvasesEnabled"
        
        case colorType = "accentColorType"
        
        case ip      = "deviceIp"
        case country = "deviceCountry"
    }
    // swiftlint:enable redundant_string_enum_value
    
    enum RegularExpressions: String {
        case pulsePassword = "(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}"
    }
    
    static var isDebug: Bool {
#if DEBUG
        return true
#endif
        return false
    }
}

extension Constants.Images {
    fileprivate enum System: String {
        case exclamationMarkTriangle = "exclamationmark.triangle"
        case heartFill               = "heart.fill"
        case arrowDownHeartFill      = "arrow.down.heart.fill"
        case trashFill               = "trash.fill"
        case textInsert              = "text.insert"
        case textAppend              = "text.append"
        case minus                   = "minus"
        case heartSlashFill          = "heart.slash.fill"
        case chevronRight            = "chevron.right"
        case eSquareFill             = "e.square.fill"
        case ellipsis                = "ellipsis"
        case playFill                = "play.fill"
        case pauseFill               = "pause.fill"
        case squareAndArrowDown      = "square.and.arrow.down"
        case squareAndArrowUp        = "square.and.arrow.up"
        case appleLogo               = "apple.logo"
        case xCircleFill             = "x.circle.fill"
        case eye                     = "eye"
        case eyeSlash                = "eye.slash"
        case gear                    = "gear"
        case magnifyingGlass         = "magnifyingglass"
        case heart                   = "heart"
        case musicNote               = "music.note"
        case forwardFill             = "forward.fill"
        
        var image: UIImage? {
            return UIImage(systemName: self.rawValue)
        }
    }
    
    fileprivate enum Custom: String {
        case soundcloudLogo = "SoundcloudLogo"
        
        var image: UIImage? {
            return UIImage(named: self.rawValue)
        }
    }
}

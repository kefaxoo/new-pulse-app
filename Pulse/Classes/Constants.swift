//
//  Constants.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import UIKit

enum Constants {
    static var localPulseBaseUrl = "http://192.168.0.102:8000"
    
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
        case actionsNowPlaying
        case playlists
        case audioDestination
        case minVolume
        case maxVolume
        case previousTrack
        case googleLogo
        case yandexMusicLogo
        case yandexPlusLogo
        case openIn
        case mainNonSelected
        case mainSelected
        case pulseLogo
        case dolbyAtmosLogo
        case losslessLogo
        case deezerLogo
        case appleMusicLogo
        case spotifyLogo
        case youtubeLogo
        case youtubeMusicLogo
        case addToLibraryNowPlaying
        
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
                case .libraryNonSelected, .addToLibraryNowPlaying:
                    type = .heart
                case .tracks:
                    type = .musicNote
                case .nextTrack:
                    type = .forwardFill
                case .actionsNowPlaying:
                    type = .ellipsisCircleFill
                case .playlists:
                    type = .musicNoteList
                case .audioDestination:
                    type = .airplayAudio
                case .minVolume:
                    type = .speakerFill
                case .maxVolume:
                    type = .speakerWave3Fill
                case .previousTrack:
                    type = .backwardFill
                case .openIn:
                    type = .rectanglePortraitAndArrowRight
                case .mainNonSelected:
                    type = .house
                case .mainSelected:
                    type = .houseFill
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
                case .googleLogo:
                    type = .googleLogo
                case .yandexMusicLogo:
                    type = .yandexMusicLogo
                case .yandexPlusLogo:
                    type = .yandexPlusLogo
                case .pulseLogo:
                    type = .pulseLogo
                case .dolbyAtmosLogo:
                    type = .dolbyAtmosLogo
                case .losslessLogo:
                    type = .losslessLogo
                case .deezerLogo:
                    type = .deezerLogo
                case .appleMusicLogo:
                    type = .appleMusicLogo
                case .spotifyLogo:
                    type = .spotifyLogo
                case .youtubeLogo:
                    type = .youtubeLogo
                case .youtubeMusicLogo:
                    type = .youtubeMusicLogo
                default:
                    return nil
            }
            
            return type.image
        }
    }
    
    // swiftlint:disable redundant_string_enum_value
    enum KeychainService: String {
        case pulseCredentials  = "pulseCredentials"
        case pulseToken        = "pulseToken"
        case pulseRefreshToken = "pulseRefreshToken"
        
        case soundcloudAccessToken  = "soundcloudAccessToken"
        case soundcloudRefreshToken = "soundcloudRefreshToken"
        case soundcloudUser         = "soundcloudUser"
        case yandexMusicAccessToken = "yandexMusicAccessToken"
    }
    
    enum UserDefaultsKeys: String {
        case appEnvironment = "appEnvironment"
        
        case pulseUsername      = "pulseUsername"
        case pulseExpireAt      = "pulseExpireAt"
        case pulseAccessDenied = "pulse.accessDenied"
        
        case soundcloudUserId = "soundcloudUserId"
        case soundcloudUser   = "soundcloudUser"
        
        case soundcloudLike   = "soundcloud.like"
        case soundcloudSource = "soundcloud.source"
        
        case yandexMusicSource           = "yandexMusic.source"
        case yandexMusicUid              = "yandexMusic.uid"
        case yandexMusicDisplayName      = "yandexMusic.displayName"
        case yandexMusicIsPlus           = "yandexMusic.isPlus"
        case yandexMusicLike             = "yandexMusic.like"
        case yandexMusicStreamingQuality = "yandexMusic.quality.streaming"
        case yandexMusicDownloadQuality  = "yandexMusic.quality.download"
        
        case autoDownload          = "general.autoDownload"
        case isAdultContentEnabled = "general.isAdultContentEnabled"
        case isCanvasesEnabled     = "general.isCanvasesEnabled"
        case appearance            = "general.appearance"
        
        case colorType = "accentColorType"
        
        case ip      = "deviceIp"
        case country = "deviceCountry"
        
        case featuresLastUpdate = "featuresLastUpdate"
        
        case lastTabBarIndex = "lastTabBarIndex"
        
        case deviceModel = "device.model"
    }
    // swiftlint:enable redundant_string_enum_value
    
    enum RegularExpressions: String {
        case pulsePassword = "(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}"
    }
    
    enum Soundcloud: String {
        case clientId     = "5acc74891941cfc73ec8ee2504be6617"
        case clientSecret = "ca2b69301bd1f73985a9b47224a2a239"
        case redirectLink = "https://quodlibet.github.io/callbacks/soundcloud.html"
    }
    
    static var isDebug: Bool {
        return AppEnvironment.current != .releaseProd
    }
}

extension Constants.Images {
    fileprivate enum System: String {
        case exclamationMarkTriangle        = "exclamationmark.triangle"
        case heartFill                      = "heart.fill"
        case arrowDownHeartFill             = "arrow.down.heart.fill"
        case trashFill                      = "trash.fill"
        case textInsert                     = "text.insert"
        case textAppend                     = "text.append"
        case minus                          = "minus"
        case heartSlashFill                 = "heart.slash.fill"
        case chevronRight                   = "chevron.right"
        case eSquareFill                    = "e.square.fill"
        case ellipsis                       = "ellipsis"
        case playFill                       = "play.fill"
        case pauseFill                      = "pause.fill"
        case squareAndArrowDown             = "square.and.arrow.down"
        case squareAndArrowUp               = "square.and.arrow.up"
        case appleLogo                      = "apple.logo"
        case xCircleFill                    = "x.circle.fill"
        case eye                            = "eye"
        case eyeSlash                       = "eye.slash"
        case gear                           = "gear"
        case magnifyingGlass                = "magnifyingglass"
        case heart                          = "heart"
        case musicNote                      = "music.note"
        case forwardFill                    = "forward.fill"
        case ellipsisCircleFill             = "ellipsis.circle.fill"
        case musicNoteList                  = "music.note.list"
        case airplayAudio                   = "airplayaudio"
        case speakerFill                    = "speaker.fill"
        case speakerWave3Fill               = "speaker.wave.3.fill"
        case backwardFill                   = "backward.fill"
        case rectanglePortraitAndArrowRight = "rectangle.portrait.and.arrow.right"
        case house                          = "house"
        case houseFill                      = "house.fill"
        
        var image: UIImage? {
            return UIImage(systemName: self.rawValue)
        }
    }
    
    fileprivate enum Custom: String {
        case soundcloudLogo   = "SoundcloudLogo"
        case googleLogo       = "GoogleLogo"
        case yandexMusicLogo  = "YandexMusicLogo"
        case yandexPlusLogo   = "YandexPlusLogo"
        case pulseLogo        = "iconForLaunchScreen"
        case dolbyAtmosLogo   = "DolbyAtmosLogo"
        case losslessLogo     = "LosslessLogo"
        case deezerLogo       = "DeezerLogo"
        case appleMusicLogo   = "AppleMusicLogo"
        case spotifyLogo      = "SpotifyLogo"
        case youtubeLogo      = "YoutubeLogo"
        case youtubeMusicLogo = "YoutubeMusicLogo"
        
        var image: UIImage? {
            return UIImage(named: self.rawValue)
        }
    }
}

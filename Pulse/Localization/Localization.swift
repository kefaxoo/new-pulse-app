//
//  Localization.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.11.23.
//

import Foundation

protocol Localizable {
    var localization: String { get }
}

enum Localization {}

// MARK: -
// MARK: Words
extension Localization {
    enum Words: String {
        case signIn      = "words.sign.in"
        case signUp      = "words.sign.up"
        case email       = "words.email"
        case password    = "words.password"
        case library     = "words.library"
        case search      = "words.search"
        case settings    = "words.settings"
        case share       = "words.share"
        case error       = "words.error"
        case tracks      = "words.tracks"
        case yandexMusic = "words.yandexMusic"
        case signOut     = "words.signOut"
        case playlists   = "words.playlists"
        case menu        = "words.menu"
        case vk          = "words.vk"
        case blue        = "words.blue"
        case cyan        = "words.cyan"
        case green       = "words.green"
        case indigo      = "words.indigo"
        case mint        = "words.mint"
        case orange      = "words.orange"
        case pink        = "words.pink"
        case purple      = "words.purple"
        case red         = "words.red"
        case teal        = "words.teal"
        case yellow      = "words.yellow"
        case albums      = "words.albums"
        case artists     = "words.artists"
        case general     = "words.general"
        case appearance  = "words.appearance"
        case help        = "words.help"
        case main        = "words.main"
        case cancel      = "words.cancel"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: -
// MARK: Controllers
extension Localization {
    enum Controllers {
        enum Auth {}
        enum SignIn {}
        enum Playlists {}
        enum Tracks {}
        enum Search {}
        enum AccountBlocked {}
    }
}

// MARK: Auth
extension Localization.Controllers.Auth {
    enum Buttons: String {
        case continueWithApple = "controller.auth.button.continue.with.apple"
        case continueWithGoogle = "controller.auth.button.continue.with.google"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: Sign In
extension Localization.Controllers.SignIn {
    enum Buttons: String {
        case forgetPassword = "controller.signIn.button.forget.password"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: Playlists
extension Localization.Controllers.Playlists {
    enum SearchControllers: String {
        case typeQuery = "controller.playlists.searchController.typeQuery"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: Tracks
extension Localization.Controllers.Tracks {
    enum SearchControllers: String {
        case typeQuery = "controller.tracks.searchController.typeQuery"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
    
    enum ContentUnavailableViews: String {
        case noContent = "controller.track.contentUnavailableView.noContent"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: Search
extension Localization.Controllers.Search {
    enum SearchControllers: String {
        case typeQuery = "controller.search.searchController.typeQuery"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
    
    enum ContentUnavailableViews: String {
        case typeQuery = "controller.search.contentUnavailableView.typeQuery"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: Account Blocked
extension Localization.Controllers.AccountBlocked {
    enum Label: String, Localizable {
        case title = "controller.accountBlocked.label.title"
        case description = "controller.accountBlocked.label.description"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: -
// MARK: Pop Up
extension Localization {
    enum PopUp {
        enum VerifyPulseAccount: String {
            case description = "popUp.verifyPulseAccount.description"
            
            func localization(with parameter: String) -> String {
                return self.rawValue.localized(parameters: [parameter])
            }
        }
        
        enum Logout: String {
            case title = "popUp.logout.title"
            
            var localization: String {
                return self.rawValue.localized
            }
        }
    }
}

extension Localization.PopUp.VerifyPulseAccount {
    enum Buttons: String {
        case openTelegramBot = "popUp.verifyPulseAccount.buttons.openTelegramBot"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
    
    enum Lables: String {
        case verificationCode = "popUp.verifyPulseAccount.labels.verificationCode"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: -
// MARK: Views
extension Localization {
    enum Views {
        enum NowPlaying {}
        enum OpenInService {}
    }
}

// MARK: Now playing
extension Localization.Views.NowPlaying {
    enum Label: String {
        case notPlaying = "view.nowPlaying.label.notPlaying"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: Open in service
extension Localization.Views.OpenInService {
    enum Buttons: String {
        case copyUrl = "view.openInService.button.copyUrl"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: -
// MARK: Server localization
extension Localization {
    enum Server {}
}

// MARK: Localization keys
extension Localization.Server {
    enum Keys: String {
        /// Usage: .localization(with:)
        case isIncorrect = "error.something.is.incorrect"
        
        /// Usage: .localization
        case anotherSignMethod = "error.try.another.sign.method"
        
        /// Usage: .localization(with:)
        case isExist = "error.something.is.exist"
        
        /// Usage: .localization
        case exception = "error.exception"
        
        /// Usage: .localization(with:)
        case notFound = "error.something.not.found"
        
        var localization: String {
            return self.rawValue.localized
        }
        
        func localization(with parameter: String) -> String {
            return self.rawValue.localized(parameters: [parameter])
        }
    }
}

// MARK: Localization parameters
extension Localization.Server {
    enum Words: String {
        case email = "word.email"
        case user  = "word.user"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: Widgets
extension Localization.Server {
    enum Widgets: String {
        enum Button: String {
            case exclusiveTracks    = "server.widgets.button.exclusiveTracks"
            case exclusivePlaylists = "server.widgets.button.exclusivePlaylists"
            
            var localization: String {
                return self.rawValue.localized
            }
        }
        
        case exclusiveTracks    = "server.widgets.exclusiveTracks"
        case exclusivePlaylists = "server.widgets.exclusivePlaylists"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: -
// MARK: Lines
extension Localization {
    enum Lines: String {
        /// Usage: .localization(with:)
        case unknownError = "lines.unknown.error"
        
        /// Usage: .localization
        case passwordDoesntMeetRequirements = "lines.password.doesnt.meet.requirements"
        
        /// Usage: .localization(with:)
        case textInTextFieldIsEmpty = "lines.text.in.textfield.is.empty"
        
        /// Usage: .localization
        case refreshToken = "lines.refreshToken"
        
        /// Usage: .localization(with:)
        case successRefreshToken = "lines.successRefreshToken"
        
        /// Usage: .localization(with:)
        case successSignIn = "lines.successSignIn"
        
        /// Usage: .localization
        case playingLast = "lines.playingLast"
        
        /// Usage: .localization
        case playingNext = "lines.playingNext"
        
        /// Usage: .localization(with:)
        case currentSource = "lines.currentSource"
        
        /// Usage: .localization(with:)
        case currentCountry = "lines.currentCountry"
        
        /// Usage: .localization
        case yourPlaylists = "lines.yourPlaylists"
        
        /// Usage: .localization
        case likedPlaylists = "lines.likedPlaylists"
        
        /// Usage: .localization(with:)
        case user = "lines.user"
        
        /// Usage: .localization(with:)
        case signIn = "lines.signIn"
        
        /// Usage: .localization(with:)
        case likeTrackIn = "lines.likeTrackIn"
        
        /// Usage: .localization(with:)
        case appInfo = "lines.appInfo"
        
        /// Usage: .localization(with:)
        case likeTrackInDescription = "lines.likeTrackInDescription"
        
        /// Usage: .localization(with:)
        case buildNumber = "lines.buildNumber"
        
        
        func localization(with parameters: String...) -> String {
            return self.rawValue.localized(parameters: parameters)
        }
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: -
// MARK: Actions
extension Localization {
    enum Actions {
        enum ShareTrackAsLink: String {
            case shareText = "action.shareTrackAsLink.text"
            
            func localization(with parameters: String...) -> String {
                return self.rawValue.localized(parameters: parameters)
            }
        }
    }
}

// MARK: Title
extension Localization.Actions {
    enum Title: String {
        case playLast         = "action.title.playLast"
        case playNext         = "action.title.playNext"
        case openIn           = "action.title.openIn"
        case shareTrackAsFile = "action.title.shareTrackAsFile"
        case shareTrackAsLink = "action.title.shareTrackAsLink"
        case downloadTrack    = "action.title.downloadTrack"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: -
// MARK: Enums
extension Localization {
    enum Enums {
        enum Media {
            enum ArtistViewScheme {}
        }
        
        enum SettingType {}
        enum ApplicationStyle {}
        enum YandexMusicQuality: String {
            case lq = "enum.ymQuality.lq"
            case mq = "enum.ymQuality.mq"
            case hq = "enum.ymQuality.hq"
            
            var localization: String {
                return self.rawValue.localized
            }
        }
    }
}

// MARK: Media
// MARK: ArtistViewScheme
// MARK: HeaderTitle
extension Localization.Enums.Media.ArtistViewScheme {
    enum HeaderTitle: String {
        case popularTracks = "enum.media.artistViewScheme.headerTitle.popularTracks"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: SettingType
// MARK: Title
extension Localization.Enums.SettingType {
    enum Title: String {
        case adultContent     = "enum.settingType.title.adultContent"
        case `import`         = "enum.settingType.title.import"
        case canvasEnabled    = "enum.settingType.title.canvasEnabled"
        case autoDownload     = "enum.settingType.title.autoDownload"
        case about            = "enum.settingType.title.about"
        case accentColor      = "enum.settingType.title.accentColor"
        case appEnvironment   = "enum.settingType.title.appEnvironment"
        case streamingQuality = "enum.settingType.title.streamingQuality"
        case downloadQuality  = "enum.settingType.title.downloadQuality"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: Description
extension Localization.Enums.SettingType {
    enum Description: String {
        case adultContent  = "enum.settingType.description.adultContent"
        case `import`      = "enum.settingType.description.import"
        case canvasEnabled = "enum.settingType.description.canvasEnabled"
        case autoDownload  = "enum.settingType.description.autoDownload"
        case accentColor   = "enum.settingType.description.accentColor"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

// MARK: ApplicationStyle
// MARK: Title
extension Localization.Enums.ApplicationStyle {
    enum Title: String {
        case light  = "enum.applicationStyle.title.light"
        case dark   = "enum.applicationStyle.title.dark"
        case system = "enum.applicationStyle.title.system"
        
        var localization: String {
            return self.rawValue.localized
        }
    }
}

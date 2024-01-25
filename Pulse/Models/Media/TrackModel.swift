//
//  TrackModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import UIKit
import PulseUIComponents

enum TrackLibraryState {
    case added
    case downloaded
    case none
    
    var image: UIImage? {
        let imageType: Constants.Images?
        switch self {
            case .added:
                imageType = .inLibrary
            case .downloaded:
                imageType = .downloaded
            case .none:
                imageType = nil
        }
        
        return imageType?.image
    }
}

final class TrackModel {
    enum Labels: String {
        case dolbyAtmos
        case lossless
        case none = ""
        
        var image: UIImage? {
            switch self {
                case .dolbyAtmos:
                    return Constants.Images.dolbyAtmosLogo.image
                case .lossless:
                    return Constants.Images.losslessLogo.image
                case .none:
                    return nil
            }
        }
    }
    
    let id         : String
    let title      : String
    let artist     : ArtistModel?
    let artists    : [ArtistModel]
    let service    : ServiceType
    let artistText : String
    let shareLink  : String
    let source     : SourceType
    let isAvailable: Bool
    
    var `extension`    = "mp3"
    var dateAdded      : Int
    var image          : ImageModel?
    var playableLinks  : PlayableLinkModel?
    var cachedFilename = ""
    var isSynced       = false
    var subtitle       : String?
    var yandexMusicId  : Int?
    var spotifyId      : String?
    var canvasLink     : String?
    var labels         = [Labels]()
    var isExplicit     = false
    var libraryTrackFilename: String {
        return "Tracks/\(self.trackFilename)"
    }
    
    var trackFilename  : String {
        return "\(self.service.rawValue)-\(self.id).\(self.extension)"
    }
    
    var libraryState: TrackLibraryState {
        if LibraryManager.shared.isTrackDownloaded(self) {
            return .downloaded
        } else if LibraryManager.shared.isTrackInLibrary(self) {
            return .added
        }
        
        return .none
    }
    
    func libraryState(_ completion: @escaping((TrackLibraryState) -> ())) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            
            if LibraryManager.shared.isTrackDownloaded(self) {
                completion(.downloaded)
                return
            } else if LibraryManager.shared.isTrackInLibrary(self) {
                completion(.added)
                return
            }
            
            completion(.none)
        }
    }
    
    init(_ track: MuffonTrack) {
        self.id            = "\(track.source.id)"
        self.title         = track.title
        self.image         = ImageModel(track.image)
        self.playableLinks = PlayableLinkModel(track.audio)
        self.service       = track.source.service
        self.shareLink     = track.source.links?.shareLink ?? ""
        self.extension     = track.extension
        self.source        = .muffon
        self.isAvailable   = track.audio.isAvailable
        self.dateAdded     = Int(Date().timeIntervalSince1970)
        if track.artist.id == -1,
           let artist = track.artists.first(where: { $0.name == track.artist.name }) {
            self.artist = ArtistModel(artist)
        } else {
            self.artist = ArtistModel(track.artist)
        }
        
        self.artists    = track.artists.map({ ArtistModel($0) })
        self.artistText = self.artists.names
    }
    
    init(_ track: LibraryTrackModel) {
        self.id             = track.id
        self.title          = track.title
        self.artist         = LibraryManager.shared.findLibraryArtist(id: track.artistId)
        self.service        = ServiceType(rawValue: track.service) ?? .none
        self.shareLink      = track.shareLink
        self.extension      = track.extension
        self.image          = ImageModel(coverFilename: track.coverFilename)
        self.source         = SourceType(rawValue: track.source) ?? .none
        self.cachedFilename = track.trackFilename
        self.isAvailable    = true
        self.isSynced       = track.isSynced
        self.dateAdded      = track.dateAdded
        var artists = [ArtistModel]()
        track.artistIds.forEach { id in
            guard let artist = LibraryManager.shared.findLibraryArtist(id: id) else { return }
            
            artists.append(artist)
        }
        
        self.artists    = artists
        self.artistText = artists.names
        
        if !track.trackFilename.isEmpty {
            self.playableLinks = PlayableLinkModel(URL(filename: track.trackFilename, path: .documentDirectory)?.absoluteString ?? "")
        }
        
        switch self.service {
            case .yandexMusic:
                YandexMusicProvider.shared.trackInfo(id: track.id) { [weak self] yandexMusicTrack in
                    self?.artist?.image = ImageModel(yandexMusicTrack.artists.first?.cover)
                }
            default:
                break
        }
        
        self.isExplicit = track.isExplicit
        self.subtitle   = track.subtitle
        self.labels     = track.labels.map({ Labels(rawValue: $0) ?? .none }).filter({ $0 != .none })
    }
    
    init(_ track: SoundcloudTrack) {
        self.id            = "\(track.id)"
        self.title         = track.title
        self.image         = ImageModel(track.coverLink ?? "")
        self.service       = .soundcloud
        self.shareLink     = "https://song.link/sc/\(track.id)"
        self.source        = .soundcloud
        self.extension     = "mp3"
        self.isAvailable   = true
        self.dateAdded     = Int(Date().timeIntervalSince1970)
        self.artist        = ArtistModel(track.user)
        self.artists       = [ArtistModel(track.user)]
        self.artistText    = self.artists.names
    }
    
    init(_ track: YandexMusicTrack) {
        self.id    = track.id
        self.title = track.title
        if let artist = track.artists.first {
            self.artist = ArtistModel(artist)
        } else {
            self.artist = nil
        }
        
        self.artists     = track.artists.map({ ArtistModel($0) })
        self.service     = .yandexMusic
        self.artistText  = track.artists.map({ $0.name }).joined(separator: ", ")
        self.shareLink   = "https://song.link/ya/\(track.id)"
        self.source      = .yandexMusic
        self.isAvailable = track.isAvailable
        self.image       = ImageModel(small: track.coverLink(for: .small), original: track.coverLink(for: .xl))
        self.dateAdded   = Int(Date().timeIntervalSince1970)
        self.isExplicit  = track.isExplicit
    }
    
    init(_ track: PulseExclusiveTrack) {
        self.id = "\(track.id)"
        self.title = track.title
        self.artists = track.artists?.map({ ArtistModel($0) }) ?? []
        self.artist = self.artists.first
        self.service = .pulse
        self.artistText = self.artists.compactMap({ $0.name }).joined(separator: ", ")
        self.`extension` = track.trackExtension
        self.source = .pulse
        self.isAvailable = true
        self.dateAdded = Int(Date().timeIntervalSince1970)
        self.playableLinks = PlayableLinkModel(track.playableLink)
        self.image = ImageModel(track.album?.coverLink)
        self.subtitle = track.subtitle
        self.yandexMusicId = track.yandexMusicId
        self.spotifyId = track.spotifyId
        self.canvasLink = track.canvasLink
        self.labels = track.labels.map({ $0.trackLabel })
        self.isExplicit = track.isExplicit
        if let spotifyId = track.spotifyId {
            self.shareLink = "https://song.link/s/\(spotifyId)"
        } else if let yandexMusicId = track.yandexMusicId {
            self.shareLink = "https://song.link/ya/\(yandexMusicId)"
        } else {   
            self.shareLink = ""
        }
    }
    
    var json: [String: Any] {
        var dict: [String: Any] = [
            "id"   : self.id,
            "title": self.title
        ]
        
        if let artist {
            dict["artist"] = artist.json(service: self.service)
        }
        
        if !artists.isEmpty {
            dict["artists"] = artists.map({ $0.json(service: self.service) })
        }
        
        dict["service"]   = self.service.rawValue
        dict["source"]    = self.source.rawValue
        dict["dateAdded"] = self.dateAdded
        
        return dict
    }
    
    var newJson: [String: Any] {
        let dict: [String: Any] = [
            "id": "\(self.id)",
            "service": self.service.rawValue,
            "source": self.source.rawValue,
            "dateAdded": self.dateAdded
        ]
        
        return dict
    }
    
    var needFetchingPlayableLinks: Bool {
        return SessionCacheManager.shared.isTrackInCache(self) || (self.playableLinks?.streamingLinkNeedsToRefresh ?? true)
    }
}

// MARK: -
// MARK: Override methods
extension TrackModel: Equatable {
    static func == (lhs: TrackModel, rhs: TrackModel) -> Bool {
        return lhs.id == rhs.id && lhs.source == rhs.source && lhs.service == rhs.service
    }
}

extension [TrackModel] {
    var sorted: [TrackModel] {
        return self.sorted { firstObj, secondObj in
            return firstObj.dateAdded > secondObj.dateAdded
        }
    }
}

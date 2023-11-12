//
//  TrackModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import UIKit

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
    let id         : Int
    let title      : String
    let artist     : ArtistModel?
    let artists    : [ArtistModel]
    let service    : ServiceType
    let artistText : String
    let shareLink  : String
    let `extension`: String
    let source     : SourceType
    let isAvailable: Bool
    
    var dateAdded      : Int
    var image          : ImageModel?
    var playableLinks  : PlayableLinkModel?
    var cachedFilename = ""
    var isSynced       = false
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
    
    init(_ track: MuffonTrack) {
        self.id            = track.source.id
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
    }
    
    init(_ track: SoundcloudTrack) {
        self.id            = track.id
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
            "id": self.id,
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

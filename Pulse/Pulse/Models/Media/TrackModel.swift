//
//  TrackModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import Foundation

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
    
    var image          : ImageModel? = nil
    var playableLinks  : PlayableLinkModel? = nil
    var cachedFilename = ""
    var trackFilename  : String {
        return "Tracks/\(self.service.rawValue)-\(self.id).\(self.extension)"
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
        if track.artist.id == -1,
           let artist = track.artists.first(where: { $0.name == track.artist.name }) {
            self.artist = ArtistModel(artist)
        } else {
            self.artist = ArtistModel(track.artist)
        }
        
        self.artists = track.artists.map({ ArtistModel($0) })
        self.artistText    = self.artists.names
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
        var artists = [ArtistModel]()
        track.artistIds.forEach { id in
            guard let artist = LibraryManager.shared.findLibraryArtist(id: id) else { return }
            
            artists.append(artist)
        }
        
        self.artists    = artists
        self.artistText = artists.names
    }
}

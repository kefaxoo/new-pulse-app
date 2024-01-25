//
//  PlaylistModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 19.09.23.
//

import Foundation

final class PlaylistModel {
    let id         : String
    let title      : String
    let dateCreated: Int
    let source     : SourceType
    
    var image      : ImageModel?
    var dateUpdated: Int
    var trackIds   : [Int]

    init(_ playlist: LibraryPlaylistModel) {
        self.id          = playlist.id
        self.title       = playlist.title
        self.dateCreated = playlist.dateCreated
        self.dateUpdated = playlist.dateUpdated
        self.trackIds    = playlist.trackIds.map({ $0 })
        self.source      = .none
    }
    
    init(_ playlist: SoundcloudPlaylist) {
        self.id          = String(playlist.id)
        self.title       = playlist.title
        self.image       = ImageModel(playlist.artworkLink)
        self.dateCreated = playlist.dateCreated
        self.dateUpdated = playlist.dateUpdated
        self.trackIds    = []
        self.source      = .soundcloud
    }
    
    init(_ playlist: PulsePlaylist) {
        self.id          = String(playlist.id)
        self.title       = playlist.title
        self.dateCreated = -1
        self.source      = .pulse
        self.dateUpdated = -1
        self.trackIds    = playlist.tracks?.map({ $0.id }) ?? []
        self.image       = ImageModel(playlist.coverLink)
    }
}

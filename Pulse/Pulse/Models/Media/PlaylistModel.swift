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
    
    var dateUpdated: Int
    var trackIds   : [Int]

    init(_ playlist: LibraryPlaylistModel) {
        self.id          = playlist.id
        self.title       = playlist.title
        self.dateCreated = playlist.dateCreated
        self.dateUpdated = playlist.dateUpdated
        self.trackIds    = playlist.trackIds.map({ $0 })
    }
}

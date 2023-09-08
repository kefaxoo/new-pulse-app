//
//  LibaryTrackModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 8.09.23.
//

import Foundation
import RealmSwift

class LibraryTrackModel: Object {
    @Persisted dynamic var id            = -1
    @Persisted dynamic var title         = ""
    @Persisted dynamic var artist        = LibraryArtistModel()
    @Persisted dynamic var artists       = List<LibraryArtistModel>()
    @Persisted dynamic var imageFilename = ""
    @Persisted dynamic var service       = ""
    @Persisted dynamic var artistName    = ""
    
    convenience init(_ track: TrackModel) {
        self.init()
        self.id         = track.id
        self.title      = track.title
        self.artist     = track.artist.library
        self.artists    = track.artists.library
        self.service    = track.service.rawValue
        self.artistName = track.artistText
    }
}

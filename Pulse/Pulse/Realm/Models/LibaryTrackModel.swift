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
    @Persisted dynamic var artistId      = -1
    @Persisted dynamic var artistIds     = List<Int>()
    @Persisted dynamic var coverFilename = ""
    @Persisted dynamic var service       = ""
    @Persisted dynamic var artistName    = ""
    @Persisted dynamic var shareLink     = ""
    @Persisted dynamic var `extension`   = ""
    @Persisted dynamic var source        = ""
    @Persisted dynamic var trackFilename = ""
    
    convenience init(_ track: TrackModel) {
        self.init()
        self.id         = track.id
        self.title      = track.title
        self.artistId   = LibraryManager.shared.createArtistIfNeeded(track.artist)
        self.artistIds  = LibraryManager.shared.createArtistsIfNeeded(track.artists)
        self.service    = track.service.rawValue
        self.artistName = track.artistText
        self.shareLink  = track.shareLink
        self.extension  = track.extension
        self.source     = track.source.rawValue
        
        ImageManager.shared.saveCover(track) { [weak self] filename in
            guard let filename else { return }
            
            self?.coverFilename = filename
        }
        
        self.trackFilename = "\(track.source.rawValue)-\(track.id).\(track.extension)"
    }
}

//
//  LibaryTrackModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 8.09.23.
//

import Foundation
import RealmSwift

class LibraryTrackModel: Object {
    @Persisted dynamic var id            = ""
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
    @Persisted dynamic var isSynced      = false
    @Persisted dynamic var dateAdded     = 0
    @Persisted dynamic var subtitle      = ""
    @Persisted dynamic var isExplicit    = false
    @Persisted dynamic var labels        = List<String>()
    
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
        self.isSynced   = track.isSynced
        self.dateAdded  = Int(Date().timeIntervalSince1970)
        self.isExplicit = track.isExplicit
        
        let labels = List<String>()
        labels.append(objectsIn: track.labels.map({ $0.rawValue }))
        self.labels = labels
        
        if let subtitle = track.subtitle {
            self.subtitle = subtitle
        }
        
        ImageManager.shared.saveCover(track) { [weak self] filename in
            guard let filename else { return }
             
            if let libraryTrack = RealmManager<Self>().read().first(where: { $0.id == track.id }) {
                RealmManager<Self>().update { realm in
                    try? realm.write {
                        libraryTrack.coverFilename = filename
                    }
                }
            } else {
                self?.coverFilename = filename
            }
        }
    }
}

//
//  LibraryPlaylistTrackModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 19.09.23.
//

import Foundation
import RealmSwift

final class LibraryPlaylistTrackModel: LibraryTrackModel {
    @Persisted dynamic var playlistId: String = ""
    
    convenience init(_ track: TrackModel, playlistId: String) {
        self.init(track)
        
        self.playlistId = playlistId
    }
}

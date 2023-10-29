//
//  LibraryPlaylistArtistModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 19.09.23.
//

import Foundation
import RealmSwift

final class LibraryPlaylistArtistModel: LibraryArtistModel {
    @Persisted dynamic var playlistId: String = ""
    
    convenience init(_ artist: ArtistModel, playlistId: String) {
        self.init(artist)
        
        self.playlistId = playlistId
    }
}

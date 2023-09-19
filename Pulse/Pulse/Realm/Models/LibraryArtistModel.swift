//
//  LibraryArtistModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 8.09.23.
//

import Foundation
import RealmSwift

class LibraryArtistModel: Object {
    @Persisted dynamic var name = ""
    @Persisted dynamic var id   = -1
    
    convenience init(_ artist: ArtistModel) {
        self.init()
        self.name = artist.name
        self.id   = artist.id
    }
}

//
//  LibraryArtistModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 8.09.23.
//

import Foundation
import RealmSwift

final class LibraryArtistModel: Object {
    @Persisted dynamic var name: String = ""
    @Persisted dynamic var id  : Int = -1
    
    convenience init(_ artist: ArtistModel) {
        self.init()
        self.name = artist.name
        self.id   = artist.id
    }
}

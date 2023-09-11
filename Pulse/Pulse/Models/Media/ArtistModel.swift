//
//  ArtistModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import Foundation
import RealmSwift

final class ArtistModel {
    let name: String
    let id  : Int
    
    init(_ artist: MuffonArtist) {
        self.name = artist.name
        self.id   = artist.id
    }
    
    var library: LibraryArtistModel {
        return LibraryArtistModel(self)
    }
}

extension [ArtistModel] {
    var library: List<LibraryArtistModel> {
        var artists = List<LibraryArtistModel>()
        artists.append(objectsIn: self.map({ LibraryArtistModel($0) }))
        return artists
    }
}

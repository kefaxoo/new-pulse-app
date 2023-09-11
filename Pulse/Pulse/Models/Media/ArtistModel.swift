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
    
    init(_ artist: LibraryArtistModel) {
        self.name = artist.name
        self.id   = artist.id
    }
}

extension [ArtistModel] {
    var library: List<LibraryArtistModel> {
        let artists = List<LibraryArtistModel>()
        artists.append(objectsIn: self.map({ LibraryArtistModel($0) }))
        return artists
    }
    
    var names: String {
        return self.map({ $0.name }).joined(separator: ", ")
    }
}

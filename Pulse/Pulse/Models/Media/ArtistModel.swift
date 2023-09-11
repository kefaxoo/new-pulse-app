//
//  ArtistModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import Foundation

final class ArtistModel {
    let name: String
    let id  : Int
    
    init(_ artist: MuffonArtist) {
        self.name = artist.name
        self.id   = artist.id
    }
}

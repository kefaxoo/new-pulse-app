//
//  TrackModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import Foundation

final class TrackModel {
    let id           : Int
    let title        : String
    let artist       : ArtistModel
    let artists      : [ArtistModel]
    let image        : ImageModel
    let playableLinks: PlayableLinkModel
    let service      : ServiceType
    
    var artistText: String {
        return self.artists.map({ $0.name }).joined(separator: ", ")
    }
    
    init(_ track: MuffonTrack) {
        self.id            = track.source.id
        self.title         = track.title
        self.artist        = ArtistModel(track.artist)
        self.artists       = track.artists.map({ ArtistModel($0) })
        self.image         = ImageModel(track.image)
        self.playableLinks = PlayableLinkModel(track.audio)
        self.service       = track.source.service
    }
}

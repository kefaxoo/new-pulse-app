//
//  ResponsePulsePlaylistModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 15.01.24.
//

import Foundation

final class ResponsePulsePlaylistModel: Decodable {
    let id             : Int
    let title          : String
    let localizationKey: String
    let tracks         : [PulseExclusiveTrack]?
    let tracksCount    : Int?
    let coverLink      : String?
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case localizationKey
        case tracks
        case tracksCount
        case coverLink
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.localizationKey = try container.decode(String.self, forKey: .localizationKey)
        self.tracks = try container.decodeIfPresent([PulseExclusiveTrack].self, forKey: .tracks)
        self.tracksCount = try container.decodeIfPresent(Int.self, forKey: .tracksCount)
        self.coverLink = try container.decodeIfPresent(String.self, forKey: .coverLink)
    }
}

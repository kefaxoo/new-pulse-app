//
//  ResponsePulseExclusiveAlbumModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 3.01.24.
//

import Foundation

final class ResponsePulseExclusiveAlbumModel: Decodable {
    let id         : Int
    let title      : String
    let releaseDate: String?
    let artists    : [ResponsePulseExclusiveArtistModel]?
    let coverLink  : String?
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case releaseDate
        case artists
        case coverLink
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        self.artists = try container.decodeIfPresent([ResponsePulseExclusiveArtistModel].self, forKey: .artists)
        self.coverLink = try container.decodeIfPresent(String.self, forKey: .coverLink)
    }
}

//
//  ResponseDeezerArtistModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 18.02.24.
//

import Foundation

final class ResponseDeezerArtistModel: Decodable {
    let id          : Int
    let name        : String
    let pictureSmall: String
    let pictureBig  : String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case pictureSmall = "picture_small"
        case pictureBig   = "picture_xl"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.pictureSmall = try container.decode(String.self, forKey: .pictureSmall)
        self.pictureBig = try container.decode(String.self, forKey: .pictureBig)
    }
}

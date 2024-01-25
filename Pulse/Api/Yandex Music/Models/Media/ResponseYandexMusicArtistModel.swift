//
//  ResponseYandexMusicArtistModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 14.12.23.
//

import Foundation

final class ResponseYandexMusicArtistModel: Decodable {
    let id: Int
    let name: String
    let cover: YandexMusicCover?
    
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case cover
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let idRaw = try? container.decode(String.self, forKey: .id),
           let id = Int(idRaw) {
            self.id = id
        } else {
            self.id = try container.decode(Int.self, forKey: .id)
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.cover = try container.decodeIfPresent(YandexMusicCover.self, forKey: .cover)
    }
}

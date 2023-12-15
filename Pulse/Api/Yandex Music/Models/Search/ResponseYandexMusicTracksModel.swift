//
//  ResponseYandexMusicTracksModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 14.12.23.
//

import Foundation

final class ResponseYandexMusicTracksModel: Decodable {
    let total: Int
    let results: [YandexMusicTrack]
    
    enum CodingKeys: CodingKey {
        case total
        case results
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.total = try container.decode(Int.self, forKey: .total)
        self.results = try container.decode([YandexMusicTrack].self, forKey: .results)
    }
}

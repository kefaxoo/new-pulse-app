//
//  ResponseYandexMusicPlaylistModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.12.23.
//

import Foundation

final class ResponseYandexMusicPlaylistModel: Decodable {
    let id: Int
    let title: String
    let description: String?
    let cover: YandexMusicCover
    let tracksCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "uid"
        case title
        case description
        case cover
        case tracksCount = "trackCount"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.cover = try container.decode(YandexMusicCover.self, forKey: .cover)
        self.tracksCount = try container.decode(Int.self, forKey: .tracksCount)
    }
}

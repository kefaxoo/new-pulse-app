//
//  ResponseYandexMusicLibraryRootModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 25.12.23.
//

import Foundation

final class ResponseYandexMusicLibraryRootModel: Decodable {
    let tracks: [YandexMusicShortTrackInfo]
    
    enum CodingKeys: CodingKey {
        case tracks
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.tracks = try container.decode([YandexMusicShortTrackInfo].self, forKey: .tracks)
    }
}

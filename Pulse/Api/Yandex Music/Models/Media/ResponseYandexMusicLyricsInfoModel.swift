//
//  ResponseYandexMusicLyricsInfoModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 14.12.23.
//

import Foundation

final class ResponseYandexMusicLyricsInfoModel: Decodable {
    let hasSyncLyrics: Bool
    let hasTextLyrics: Bool
    
    enum CodingKeys: String, CodingKey {
        case hasSyncLyrics = "hasAvailableSyncLyrics"
        case hasTextLyrics = "hasAvailableTextLyrics"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.hasSyncLyrics = try container.decode(Bool.self, forKey: .hasSyncLyrics)
        self.hasTextLyrics = try container.decode(Bool.self, forKey: .hasTextLyrics)
    }
}

//
//  ResponseYandexMusicSearchHistoryModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 24.02.24.
//

import Foundation

final class ResponseYandexMusicSearchHistoryModel: Decodable {
    private let typeRaw: String
    let track: YandexMusicTrack?
    
    var type: SearchType {
        return SearchType.yandexMusicInit(rawValue: self.typeRaw)
    }
    
    enum CodingKeys: String, CodingKey {
        case typeRaw = "type"
        case track
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.typeRaw = try container.decode(String.self, forKey: .typeRaw)
        self.track = try container.decodeIfPresent(YandexMusicTrack.self, forKey: .track)
    }
}

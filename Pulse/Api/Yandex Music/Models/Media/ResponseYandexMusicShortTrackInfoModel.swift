//
//  ResponseYandexMusicShortTrackInfoModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 25.12.23.
//

import Foundation


final class ResponseYandexMusicShortTrackInfoModel: Decodable {
    let id: String
    
    enum CodingKeys: CodingKey {
        case id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
    }
}

//
//  ResponseYandexMusicTrackPositionModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 14.12.23.
//

import Foundation

final class ResponseYandexMusicTrackPositionModel: Decodable {
    let diskNumber : Int
    let trackNumber: Int
    
    enum CodingKeys: String, CodingKey {
        case diskNumber  = "volume"
        case trackNumber = "index"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.diskNumber = try container.decode(Int.self, forKey: .diskNumber)
        self.trackNumber = try container.decode(Int.self, forKey: .trackNumber)
    }
}

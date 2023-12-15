//
//  ResponseYandexMusicAccountStatusModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 14.12.23.
//

import Foundation

final class ResponseYandexMusicAccountStatusModel: Decodable {
    let plus: YandexPlusInfo
    
    enum CodingKeys: CodingKey {
        case plus
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
       
        self.plus = try container.decode(YandexPlusInfo.self, forKey: .plus)
    }
}

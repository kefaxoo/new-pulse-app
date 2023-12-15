//
//  ResponseYandexPlusInfoModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 14.12.23.
//

import Foundation

final class ResponseYandexPlusInfoModel: Decodable {
    let hasPlus: Bool
    
    enum CodingKeys: CodingKey {
        case hasPlus
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.hasPlus = try container.decode(Bool.self, forKey: .hasPlus)
    }
}

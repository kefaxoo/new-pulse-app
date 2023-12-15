//
//  ResponseYandexMusicBaseResultModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 14.12.23.
//

import Foundation

final class ResponseYandexMusicBaseResultModel<T>: Decodable where T: Decodable {
    let result: T
    
    enum CodingKeys: CodingKey {
        case result
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.result = try container.decode(T.self, forKey: .result)
    }
}

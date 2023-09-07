//
//  ResponsePulseCoverInfoModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import Foundation

final class ResponsePulseCoverInfoModel: Decodable {
    let cover: PulseCover
    
    enum CodingKeys: CodingKey {
        case cover
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.cover = try container.decode(PulseCover.self, forKey: .cover)
    }
}

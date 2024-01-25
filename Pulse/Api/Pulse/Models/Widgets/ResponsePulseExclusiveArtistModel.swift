//
//  ResponsePulseExclusiveArtistModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 3.01.24.
//

import Foundation

final class ResponsePulseExclusiveArtistModel: Decodable {
    let id  : Int
    let name: String
    
    enum CodingKeys: CodingKey {
        case id
        case name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
      
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
    }
}

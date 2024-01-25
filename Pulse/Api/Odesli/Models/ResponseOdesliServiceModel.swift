//
//  ResponseOdesliServiceModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.12.23.
//

import Foundation

final class ResponseOdesliServiceModel: Decodable {
    let url            : String
    let entitiyUniqueId: String
    
    enum CodingKeys: String, CodingKey {
        case url
        case entityUniqueId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.url = try container.decode(String.self, forKey: .url)
        self.entitiyUniqueId = try container.decode(String.self, forKey: .entityUniqueId)
    }
}

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
    let appleMusicUrl  : String?
    
    enum CodingKeys: String, CodingKey {
        case url
        case entityUniqueId
        case appleMusicUrl = "nativeAppUriMobile"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.url = try container.decode(String.self, forKey: .url)
        self.entitiyUniqueId = try container.decode(String.self, forKey: .entityUniqueId)
        self.appleMusicUrl = try container.decodeIfPresent(String.self, forKey: .appleMusicUrl)
    }
}

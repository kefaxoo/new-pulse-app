//
//  ResponseSoundcloudUserModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import Foundation

final class ResponseSoundcloudUserModel: Decodable {
    let id      : Int
    let username: String
    
    enum CodingKeys: CodingKey {
        case id
        case username
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
    }
}

//
//  ResponseSoundcloudUserInfoModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import Foundation

final class ResponseSoundcloudUserInfoModel: Decodable {
    let avatarLink: String
    let id        : Int
    let username  : String
    
    enum CodingKeys: String, CodingKey {
        case avatarLink = "avatar_url"
        case id
        case username
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.avatarLink = try container.decode(String.self, forKey: .avatarLink)
        self.id = try container.decode(Int.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
    }
}

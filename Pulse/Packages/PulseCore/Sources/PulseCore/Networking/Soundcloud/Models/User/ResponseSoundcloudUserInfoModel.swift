//
//  ResponseSoundcloudUserInfoModel.swift
//
//
//  Created by Bahdan Piatrouski on 11.03.24.
//

import Foundation

public final class ResponseSoundcloudUserInfoModel: Decodable {
    public let avatarLink: String
    public let id: Int
    public let username: String
    
    enum CodingKeys: String, CodingKey {
        case avatarLink = "avatar_url"
        case id
        case username
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.avatarLink = try container.decode(String.self, forKey: .avatarLink)
        self.id = try container.decode(Int.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
    }
}

//
//  ResponseYandexAccountInfoModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 14.12.23.
//

import Foundation

final class ResponseYandexAccountInfoModel: Decodable {
    let id           : String
    let displayName  : String
    let avatarPath   : String
    let isAvatarEmpty: Bool
    
    var avatarLink: String? {
        guard !self.isAvatarEmpty else { return nil }
        
        return "https://avatars.yandex.net/get-yapic/\(self.avatarPath)/islands-200"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName   = "display_name"
        case avatarPath    = "default_avatar_id"
        case isAvatarEmpty = "is_avatar_empty"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.id = try container.decode(String.self, forKey: .id)
        self.displayName = try container.decode(String.self, forKey: .displayName)
        self.avatarPath = try container.decode(String.self, forKey: .avatarPath)
        self.isAvatarEmpty = try container.decode(Bool.self, forKey: .isAvatarEmpty)
    }
}

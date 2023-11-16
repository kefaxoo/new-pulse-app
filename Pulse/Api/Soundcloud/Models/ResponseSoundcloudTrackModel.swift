//
//  ResponseSoundcloudTrackModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import Foundation

final class ResponseSoundcloudTrackModel: Decodable {
    let id          : Int
    let title       : String
    let coverLink   : String?
    let user        : SoundcloudUser
    let playableLink: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case coverLink = "artwork_url"
        case user
        case playableLink = "stream_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.coverLink = try container.decodeIfPresent(String.self, forKey: .coverLink)
        self.user = try container.decode(SoundcloudUser.self, forKey: .user)
        self.playableLink = try container.decode(String.self, forKey: .playableLink)
    }
}

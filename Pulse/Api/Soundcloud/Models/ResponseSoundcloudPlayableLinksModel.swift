//
//  ResponseSoundcloudPlayableLinksModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import Foundation

final class ResponseSoundcloudPlayableLinksModel: Decodable {
    let streamingLink: String
    
    enum CodingKeys: String, CodingKey {
        case streamingLink = "http_mp3_128_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.streamingLink = try container.decode(String.self, forKey: .streamingLink)
    }
}

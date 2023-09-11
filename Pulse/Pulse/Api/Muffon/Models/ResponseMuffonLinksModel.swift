//
//  ResponseMuffonLinksModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import Foundation

final class ResponseMuffonLinksModel: Decodable {
    let streaming: String
    let universal: String?
    
    var shareLink: String {
        return universal ?? streaming
    }
    
    enum CodingKeys: String, CodingKey {
        case streaming = "original"
        case universal = "streaming"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.streaming = try container.decode(String.self, forKey: .streaming)
        self.universal = try container.decodeIfPresent(String.self, forKey: .universal)
    }
}

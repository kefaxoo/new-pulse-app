//
//  ResponseSoundcloudErrorModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.09.23.
//

import Foundation

final class ResponseSoundcloudErrorModel: Decodable {
    let message: String
    
    enum CodingKeys: CodingKey {
        case message
    }
    
    init(errorDescription: String) {
        self.message = errorDescription
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message = try container.decode(String.self, forKey: .message)
    }
}

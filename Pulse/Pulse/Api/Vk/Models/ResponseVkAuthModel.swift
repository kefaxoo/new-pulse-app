//
//  ResponseVkAuthModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 5.09.23.
//

import Foundation

final class ResponseVkAuthModel: Decodable {
    let accessToken: String
    let userId     : Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case userId      = "user_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.userId = try container.decode(Int.self, forKey: .userId)
    }
}

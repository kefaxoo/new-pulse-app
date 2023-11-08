//
//  ResponsePulseAuthTokensModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 27.10.23.
//

import Foundation

final class ResponsePulseAuthTokensModel: Decodable {
    let accessToken: String
    let expireAt: Int
    let refreshToken: String
    
    enum CodingKeys: CodingKey {
        case accessToken
        case expireAt
        case refreshToken
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.expireAt = try container.decode(Int.self, forKey: .expireAt)
        self.refreshToken = try container.decode(String.self, forKey: .refreshToken)
    }
}

//
//  ResponsePulseLoginUserModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 1.09.23.
//

import Foundation

final class ResponsePulseLoginUserModel: PulseSuccess {
    let accessToken: String
    let expireAt   : Int?
    let isAdmin    : Bool?
    
    enum CodingKeys: CodingKey {
        case accessToken
        case expireAt
        case isAdmin
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.expireAt = try container.decodeIfPresent(Int.self, forKey: .expireAt)
        self.isAdmin = try container.decodeIfPresent(Bool.self, forKey: .isAdmin)
        
        try super.init(from: decoder)
    }
}

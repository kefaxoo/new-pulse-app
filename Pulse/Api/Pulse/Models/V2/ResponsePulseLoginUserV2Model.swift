//
//  ResponsePulseLoginUserV2Model.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 27.10.23.
//

import Foundation

final class ResponsePulseLoginUserV2Model: PulseSuccessV2 {
    let isAdmin: Bool
    let tokens: PulseAuthTokens
    
    enum CodingKeys: String, CodingKey {
        case isAdmin
        case tokens = "authorizationInfo"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.isAdmin = try container.decode(Bool.self, forKey: .isAdmin)
        self.tokens = try container.decode(PulseAuthTokens.self, forKey: .tokens)
        
        try super.init(from: decoder)
    }
}

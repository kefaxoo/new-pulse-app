//
//  ResponsePulseAccessTokenModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.10.23.
//

import Foundation

final class ResponsePulseAccessTokenModel: PulseSuccessV2 {
    let tokens: PulseAuthTokens
    
    enum CodingKeys: String, CodingKey {
        case tokens = "authorizationInfo"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.tokens = try container.decode(PulseAuthTokens.self, forKey: .tokens)
        
        try super.init(from: decoder)
    }
}

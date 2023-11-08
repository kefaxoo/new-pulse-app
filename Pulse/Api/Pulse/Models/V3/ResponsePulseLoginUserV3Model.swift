//
//  ResponsePulseLoginUserV3Model.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.11.23.
//

import Foundation

final class ResponsePulseLoginUserV3Model: PulseBaseSuccessModel {
    let tokens: PulseAuthorizationInfo
    
    enum CodingKeys: String, CodingKey {
        case tokens = "authorizationInfo"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.tokens = try container.decode(PulseAuthorizationInfo.self, forKey: .tokens)
        
        try super.init(from: decoder)
    }
}

//
//  ResponsePulseLoginUserModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 1.09.23.
//

import Foundation

final class ResponsePulseLoginUserModel: PulseSuccess {
    let accessToken: String
    let isAdmin    : Bool
    
    enum CodingKeys: CodingKey {
        case accessToken
        case isAdmin
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.isAdmin = try container.decode(Bool.self, forKey: .isAdmin)
        
        try super.init(from: decoder)
    }
}

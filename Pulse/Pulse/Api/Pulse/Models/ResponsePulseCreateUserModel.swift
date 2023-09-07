//
//  ResponsePulseCreateUserModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.08.23.
//

import Foundation

final class ResponsePulseCreateUserModel: PulseVerificationCode {
    let message: String
    
    enum CodingKeys: CodingKey {
        case message
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.message = try container.decode(String.self, forKey: .message)
        
        try super.init(from: decoder)
    }
}

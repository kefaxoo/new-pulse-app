//
//  ResponsePulseIsBlockedModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 14.01.24.
//

import Foundation

class ResponsePulseIsBlockedModel: PulseBaseSuccessModel {
    let isBlocked: Bool
    
    enum CodingKeys: CodingKey {
        case isBlocked
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.isBlocked = try container.decode(Bool.self, forKey: .isBlocked)
        
        try super.init(from: decoder)
    }
}

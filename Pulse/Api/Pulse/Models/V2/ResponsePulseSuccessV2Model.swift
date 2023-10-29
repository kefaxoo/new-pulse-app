//
//  ResponsePulseSuccessV2Model.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 25.10.23.
//

import Foundation

class ResponsePulseSuccessV2Model: PulseDefault {
    let success: String
    
    enum CodingKeys: CodingKey {
        case success
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.success = try container.decode(String.self, forKey: .success)

        try super.init(from: decoder)
    }
}

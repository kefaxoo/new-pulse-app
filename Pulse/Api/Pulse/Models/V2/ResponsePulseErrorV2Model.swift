//
//  ResponsePulseErrorV2Model.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 25.10.23.
//

import Foundation

class ResponsePulseErrorV2Model: PulseDefault {
    let error: String
    
    enum CodingKeys: CodingKey {
        case error
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.error = try container.decode(String.self, forKey: .error)
        
        try super.init(from: decoder)
    }
}

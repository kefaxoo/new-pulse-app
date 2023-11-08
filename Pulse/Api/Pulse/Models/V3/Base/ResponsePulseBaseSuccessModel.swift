//
//  ResponsePulseBaseSuccessModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.11.23.
//

import Foundation

class ResponsePulseBaseSuccessModel: PulseBaseModel {
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

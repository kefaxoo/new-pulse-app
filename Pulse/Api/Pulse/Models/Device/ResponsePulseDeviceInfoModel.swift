//
//  ResponsePulseDeviceInfoModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.02.24.
//

import Foundation

final class ResponsePulseDeviceInfoModel: PulseBaseSuccessModel {
    let model: String
    
    enum CodingKeys: CodingKey {
        case model
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.model = try container.decode(String.self, forKey: .model)
        
        try super.init(from: decoder)
    }
}

//
//  ResponsePulseSettingsRootModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.01.24.
//

import Foundation

final class ResponsePulseSettingsRootModel: PulseBaseSuccessModel {
    let settings: PulseSettings
    
    enum CodingKeys: CodingKey {
        case settings
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.settings = try container.decode(PulseSettings.self, forKey: .settings)
        
        try super.init(from: decoder)
    }
}

//
//  ResponsePulseExclusiveTrackInfoModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.01.24.
//

import Foundation

final class ResponsePulseExclusiveTrackInfoModel: PulseBaseSuccessModel {
    let exclusiveTrack: PulseExclusiveTrack
    
    enum CodingKeys: CodingKey {
        case exclusiveTrack
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.exclusiveTrack = try container.decode(PulseExclusiveTrack.self, forKey: .exclusiveTrack)
        
        try super.init(from: decoder)
    }
}

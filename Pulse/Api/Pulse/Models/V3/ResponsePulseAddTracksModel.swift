//
//  ResponsePulseAddTracksModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 12.11.23.
//

import Foundation

final class ResponsePulseAddTracksModel: PulseBaseSuccessModel {
    let toAdd: [PulseServerTrack]
    
    enum CodingKeys: CodingKey {
        case toAdd
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.toAdd = try container.decode([PulseServerTrack].self, forKey: .toAdd)
        
        try super.init(from: decoder)
    }
}

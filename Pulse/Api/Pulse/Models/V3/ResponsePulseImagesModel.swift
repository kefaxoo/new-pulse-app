//
//  ResponsePulseImagesModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 13.11.23.
//

import Foundation

final class ResponsePulseImagesModel: PulseBaseSuccessModel {
    let images: PulseCover
    
    enum CodingKeys: CodingKey {
        case images
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.images = try container.decode(PulseCover.self, forKey: .images)
        
        try super.init(from: decoder)
    }
}

//
//  ResponsePulseFeaturesModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.10.23.
//

import Foundation

final class ResponsePulseFeaturesModel: Decodable {
    let newSign: PulseFeature
    
    enum CodingKeys: CodingKey {
        case newSign
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.newSign = try container.decode(PulseFeature.self, forKey: .newSign)
    }
}

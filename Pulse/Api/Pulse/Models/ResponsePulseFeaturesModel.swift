//
//  ResponsePulseFeaturesModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.10.23.
//

import Foundation

final class ResponsePulseFeaturesModel: Decodable {
    let newSign      : PulseFeature?
    let newFeature   : PulseFeature?
    let newSoundcloud: PulseFeature?
    
    enum CodingKeys: CodingKey {
        case newSign
        case newFeature
        case newSoundcloud
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.newSign = try container.decodeIfPresent(PulseFeature.self, forKey: .newSign)
        self.newFeature = try container.decodeIfPresent(PulseFeature.self, forKey: .newFeature)
        self.newSoundcloud = try container.decodeIfPresent(PulseFeature.self, forKey: .newSoundcloud)
    }
}

//
//  ResponsePulseFeaturesModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.10.23.
//

import Foundation

final class ResponsePulseFeaturesModel: Decodable {
    let newSign      : PulseFeature?
    let newLibrary   : PulseFeature?
    let newSoundcloud: PulseFeature?
    
    enum CodingKeys: CodingKey {
        case newSign
        case newLibrary
        case newSoundcloud
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.newSign = try container.decodeIfPresent(PulseFeature.self, forKey: .newSign)
        self.newLibrary = try container.decodeIfPresent(PulseFeature.self, forKey: .newLibrary)
        self.newSoundcloud = try container.decodeIfPresent(PulseFeature.self, forKey: .newSoundcloud)
    }
}

//
//  ResponsePulseServiceSettingsModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.01.24.
//

import Foundation

final class ResponsePulseServiceSettingsModel: Decodable {
    let like   : Bool
    let source : SourceType
    let quality: PulseQualitySettings?
    
    enum CodingKeys: CodingKey {
        case like
        case source
        case quality
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.like = try container.decode(Bool.self, forKey: .like)
        self.source = SourceType(rawValue: try container.decode(String.self, forKey: .source).lowercased()) ?? .muffon
        self.quality = try container.decodeIfPresent(PulseQualitySettings.self, forKey: .quality)
    }
}

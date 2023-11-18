//
//  ResponsePulseBaseModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.11.23.
//

import Foundation

class ResponsePulseBaseModel: Decodable {
    let image                : String
    let localizationKey      : String
    let localizationParameter: String?
    let message              : String?
    
    enum CodingKeys: CodingKey {
        case image
        case localizationKey
        case localizationParameter
        case message
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.image = try container.decode(String.self, forKey: .image)
        self.localizationKey = try container.decode(String.self, forKey: .localizationKey)
        self.localizationParameter = try container.decodeIfPresent(String.self, forKey: .localizationParameter)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
    }
}

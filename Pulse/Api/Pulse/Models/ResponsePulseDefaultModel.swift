//
//  ResponsePulseDefaultModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 25.10.23.
//

import Foundation

class ResponsePulseDefaultModel: Decodable {
    let image: String
    let localizationKey: String
    let message: String?
    let responseCode: Int
    let localizationParameter: String?
    
    enum CodingKeys: CodingKey {
        case image
        case localizationKey
        case message
        case responseCode
        case localizationParameter
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.image = try container.decode(String.self, forKey: .image)
        self.localizationKey = try container.decode(String.self, forKey: .localizationKey)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.responseCode = try container.decode(Int.self, forKey: .responseCode)
        self.localizationParameter = try container.decodeIfPresent(String.self, forKey: .localizationParameter)
    }
}

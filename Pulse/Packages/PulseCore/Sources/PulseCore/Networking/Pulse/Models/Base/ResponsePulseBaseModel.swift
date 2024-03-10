//
//  File.swift
//  
//
//  Created by Bahdan Piatrouski on 9.03.24.
//

import Foundation

public class ResponsePulseBaseModel: Decodable {
    public let image: String
    public let message: String?
    public let localizationKey: String
    public let localizedMessage: String?
    public let localizationParameter: String?
    
    enum CodingKeys: String, CodingKey {
        case image
        case message
        case localizationKey
        case localizedMessage = "localizable"
        case localizationParameter
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.image = try container.decode(String.self, forKey: .image)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.localizationKey = try container.decode(String.self, forKey: .localizationKey)
        self.localizedMessage = try container.decodeIfPresent(String.self, forKey: .localizedMessage)
        self.localizationParameter = try container.decodeIfPresent(String.self, forKey: .localizationParameter)
    }
}

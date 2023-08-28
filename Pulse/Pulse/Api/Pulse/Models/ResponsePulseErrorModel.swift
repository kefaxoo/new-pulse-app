//
//  ResponsePulseErrorModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import Foundation

final class ResponsePulseErrorModel: Decodable {
    let errorDescription: String
    let image           : String
    
    enum CodingKeys: CodingKey {
        case errorDescription
        case image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.errorDescription = try container.decode(String.self, forKey: .errorDescription)
        self.image = try container.decode(String.self, forKey: .image)
    }
}

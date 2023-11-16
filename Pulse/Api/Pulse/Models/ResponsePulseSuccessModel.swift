//
//  ResponsePulseSuccessModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 1.09.23.
//

import Foundation

class ResponsePulseSuccessModel: Decodable {
    let success: String
    let image  : String
    
    enum CodingKeys: CodingKey {
        case success
        case image
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.success = try container.decode(String.self, forKey: .success)
        self.image = try container.decode(String.self, forKey: .image)
    }
}

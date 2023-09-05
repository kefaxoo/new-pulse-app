//
//  ResponseVkErrorModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 5.09.23.
//

import Foundation

final class ResponseVkErrorModel: Decodable {
    let errorType: String
    
    
    enum CodingKeys: String, CodingKey {
        case errorType = "error_type"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.errorType = try container.decode(String.self, forKey: .errorType)
    }
}

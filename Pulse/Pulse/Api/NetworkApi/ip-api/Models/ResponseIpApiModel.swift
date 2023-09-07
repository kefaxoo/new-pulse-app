//
//  ResponseIpApiModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import Foundation

final class ResponseIpApiModel: Decodable {
    let status     : String
    let countryCode: String?
    
    enum CodingKeys: CodingKey {
        case status
        case countryCode
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.status = try container.decode(String.self, forKey: .status)
        self.countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
    }
}

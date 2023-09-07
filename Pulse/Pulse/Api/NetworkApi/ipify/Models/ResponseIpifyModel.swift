//
//  ResponseIpifyModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import Foundation

final class ResponseIpifyModel: Decodable {
    let ip: String
    
    enum CodingKeys: CodingKey {
        case ip
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.ip = try container.decode(String.self, forKey: .ip)
    }
}

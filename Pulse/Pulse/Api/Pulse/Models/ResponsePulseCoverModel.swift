//
//  ResponsePulseCoverModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.08.23.
//

import Foundation

final class ResponsePulseCoverModel: Decodable {
    let small : String
    let medium: String
    let big   : String
    let xl    : String
    
    enum CodingKeys: CodingKey {
        case small
        case medium
        case big
        case xl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.small = try container.decode(String.self, forKey: .small)
        self.medium = try container.decode(String.self, forKey: .medium)
        self.big = try container.decode(String.self, forKey: .big)
        self.xl = try container.decode(String.self, forKey: .xl)
    }
}

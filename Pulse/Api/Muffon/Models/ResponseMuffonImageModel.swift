//
//  ResponseMuffonImageModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import Foundation

final class ResponseMuffonImageModel: Decodable {
    let original  : String
    let large     : String
    let medium    : String
    let small     : String
    let extraSmall: String
    
    enum CodingKeys: String, CodingKey {
        case original
        case large
        case medium
        case small
        case extraSmall = "extrasmall"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.original = try container.decode(String.self, forKey: .original)
        self.large = try container.decode(String.self, forKey: .large)
        self.medium = try container.decode(String.self, forKey: .medium)
        self.small = try container.decode(String.self, forKey: .small)
        self.extraSmall = try container.decode(String.self, forKey: .extraSmall)
    }
}

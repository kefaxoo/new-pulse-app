//
//  ResponseMuffonSourceModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import Foundation

final class ResponseMuffonSourceModel: Decodable {
    fileprivate let name: String
    let id: Int
    let links: MuffonLinks?
    
    var service: ServiceType {
        return ServiceType.fromMuffon(name)
    }
    
    enum CodingKeys: CodingKey {
        case name
        case id
        case links
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.id = try container.decode(Int.self, forKey: .id)
        self.links = try container.decodeIfPresent(MuffonLinks.self, forKey: .links)
    }
}

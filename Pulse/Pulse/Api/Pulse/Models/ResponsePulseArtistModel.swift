//
//  ResponsePulseArtistModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 15.09.23.
//

import Foundation

final class ResponsePulseArtistModel: Decodable {
    let id  : String
    let name: String
    
    fileprivate let serviceRawValue: String
    
    var service: ServiceType {
        return ServiceType(rawValue: serviceRawValue) ?? .none
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case serviceRawValue = "service"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.serviceRawValue = try container.decode(String.self, forKey: .serviceRawValue)
    }
}

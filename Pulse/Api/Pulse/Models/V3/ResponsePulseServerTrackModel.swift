//
//  ResponsePulseServerTrackModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 12.11.23.
//

import Foundation

final class ResponsePulseServerTrackModel: Decodable {
    fileprivate let serviceRaw: String
    fileprivate let sourceRaw : String
    
    let id       : String
    let dateAdded: Int
    
    var service: ServiceType {
        return ServiceType(rawValue: self.serviceRaw) ?? .none
    }
    
    var source: SourceType {
        return SourceType(rawValue: self.sourceRaw) ?? .none
    }
    
    enum CodingKeys: String, CodingKey {
        case serviceRaw = "service"
        case sourceRaw  = "source"
        case id
        case dateAdded
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.serviceRaw = try container.decode(String.self, forKey: .serviceRaw)
        self.sourceRaw = try container.decode(String.self, forKey: .sourceRaw)
        self.id = try container.decode(String.self, forKey: .id)
        self.dateAdded = try container.decode(Int.self, forKey: .dateAdded)
    }
}

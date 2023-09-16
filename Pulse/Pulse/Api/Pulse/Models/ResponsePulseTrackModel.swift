//
//  ResponsePulseTrackModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 15.09.23.
//

import Foundation

final class ResponsePulseTrackModel: Decodable {
    let id       : String
    let dateAdded: Int
    
    fileprivate let serviceRawValue: String
    fileprivate let sourceRawValue : String
    
    var service: ServiceType {
        return ServiceType(rawValue: serviceRawValue) ?? .none
    }
    
    var source: SourceType {
        return SourceType(rawValue: sourceRawValue) ?? .muffon
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case dateAdded
        case serviceRawValue = "service"
        case sourceRawValue  = "source"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.serviceRawValue = try container.decode(String.self, forKey: .serviceRawValue)
        self.sourceRawValue = try container.decode(String.self, forKey: .sourceRawValue)
        self.dateAdded = try container.decode(Int.self, forKey: .dateAdded)
    }
}

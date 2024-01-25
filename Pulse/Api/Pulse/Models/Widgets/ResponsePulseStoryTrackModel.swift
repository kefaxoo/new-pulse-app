//
//  ResponsePulseStoryTrackModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.01.24.
//

import Foundation

final class ResponsePulseStoryTrackModel: Decodable {
    let id     : String
    let service: ServiceType
    let source : SourceType
    
    enum CodingKeys: CodingKey {
        case id
        case service
        case source
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        if let service = try? container.decodeIfPresent(String.self, forKey: .service) {
            self.service = ServiceType(rawValue: service) ?? .none
        } else {
            self.service = .none
        }
        
        if let source = try? container.decodeIfPresent(String.self, forKey: .source) {
            self.source = SourceType(rawValue: source.lowercased()) ?? .none
        } else {
            self.source = .none
        }
    }
}

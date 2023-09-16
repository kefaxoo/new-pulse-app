//
//  ResponsePulseTrackModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 15.09.23.
//

import Foundation

final class ResponsePulseTrackModel: Decodable {
    let id: String
    let title: String
    let artist: PulseArtist?
    let artists: [PulseArtist]?
    
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
        case title
        case artist
        case artists
        case serviceRawValue = "service"
        case sourceRawValue  = "source"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.artist = try container.decodeIfPresent(PulseArtist.self, forKey: .artist)
        self.artists = try container.decodeIfPresent([PulseArtist].self, forKey: .artists)
        self.serviceRawValue = try container.decode(String.self, forKey: .serviceRawValue)
        self.sourceRawValue = try container.decode(String.self, forKey: .sourceRawValue)
    }
}

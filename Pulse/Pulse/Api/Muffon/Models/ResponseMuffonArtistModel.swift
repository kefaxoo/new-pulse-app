//
//  ResponseMuffonArtistModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import Foundation

final class ResponseMuffonArtistModel: Decodable {
    fileprivate let source: MuffonSource?
    
    let name: String
    var service: ServiceType {
        return source?.service ?? .none
    }
    
    var id: Int {
        return source?.id ?? -1
    }
    
    enum CodingKeys: CodingKey {
        case source
        case name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.source = try container.decodeIfPresent(MuffonSource.self, forKey: .source)
        self.name = try container.decode(String.self, forKey: .name)
    }
}

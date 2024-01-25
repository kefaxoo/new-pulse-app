//
//  ResponseOdesliRootModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 30.12.23.
//

import Foundation

final class ResponseOdesliRootModel: Decodable {
    let pageUrl : String
    let services: OdesliLinks
    
    enum CodingKeys: String, CodingKey {
        case pageUrl
        case services = "linksByPlatform"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.pageUrl = try container.decode(String.self, forKey: .pageUrl)
        self.services = try container.decode(OdesliLinks.self, forKey: .services)
    }
}

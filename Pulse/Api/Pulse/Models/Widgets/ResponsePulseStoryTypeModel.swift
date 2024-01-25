//
//  ResponsePulseStoryTypeModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.01.24.
//

import Foundation

final class ResponsePulseStoryTypeModel: Decodable {
    let id              : Int
    let title           : String
    let localizationKey : String
    let localizableTitle: String?
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case localizationKey
        case localizableTitle
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.localizationKey = try container.decode(String.self, forKey: .localizationKey)
        self.localizableTitle = try container.decode(String.self, forKey: .localizableTitle)
    }
}

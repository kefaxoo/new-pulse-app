//
//  ResponsePulseBaseContentModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 12.11.23.
//

import Foundation

class ResponsePulseBaseContentModel<T>: PulseBaseSuccessModel where T: Decodable {
    let content    : [T]
    let contentType: String
    let itemsCount : Int
    let nextPage   : String?
    
    enum CodingKeys: CodingKey {
        case content
        case contentType
        case itemsCount
        case nextPage
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.content = try container.decode([T].self, forKey: .content)
        self.contentType = try container.decode(String.self, forKey: .contentType)
        self.itemsCount = try container.decode(Int.self, forKey: .itemsCount)
        self.nextPage = try container.decodeIfPresent(String.self, forKey: .nextPage)
        
        try super.init(from: decoder)
    }
}

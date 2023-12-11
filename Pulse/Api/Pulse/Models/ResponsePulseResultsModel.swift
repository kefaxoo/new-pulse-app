//
//  ResponsePulseResultsModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 15.09.23.
//

import Foundation

final class ResponsePulseResultsModel<T>: Decodable where T: Decodable {
    let count  : Int
    let results: [T]
    
    enum CodingKeys: CodingKey {
        case count
        case results
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.count = try container.decode(Int.self, forKey: .count)
        self.results = try container.decode([T].self, forKey: .results)
    }
}

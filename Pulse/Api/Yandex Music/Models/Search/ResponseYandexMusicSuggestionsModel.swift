//
//  ResponseYandexMusicSuggestionsModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 24.02.24.
//

import Foundation

final class ResponseYandexMusicSuggestionsModel: Decodable {
    let suggestions: [String]
    
    enum CodingKeys: CodingKey {
        case suggestions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.suggestions = try container.decode([String].self, forKey: .suggestions)
    }
}

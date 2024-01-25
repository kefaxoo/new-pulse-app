//
//  ResponseYandexMusicLibraryModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 25.12.23.
//

import Foundation

final class ResponseYandexMusicLibraryModel: Decodable {
    let library: YandexMusicLibraryRoot
    
    enum CodingKeys: CodingKey {
        case library
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.library = try container.decode(YandexMusicLibraryRoot.self, forKey: .library)
    }
}

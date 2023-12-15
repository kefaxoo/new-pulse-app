//
//  ResponseYandexMusicCoverModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 14.12.23.
//

import Foundation

final class ResponseYandexMusicCoverModel: Decodable {
    fileprivate let uri: String
    
    func cover(for size: YandexMusicCoverType) -> String {
        return "https://\(self.uri.replacingOccurrences(of: "%%", with: size.rawValue))"
    }
    
    enum CodingKeys: CodingKey {
        case uri
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.uri = try container.decode(String.self, forKey: .uri)
    }
}

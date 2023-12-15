//
//  ResponseYandexMusicSearchModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 14.12.23.
//

import Foundation

final class ResponseYandexMusicSearchModel: Decodable {
    let page   : Int
    let perPage: Int
    let tracks : YandexMusicTracks?
    
    var totalResults: Int {
        if let tracks {
            return tracks.total
        }
        
        return 0
    }
    
    var results: [Decodable] {
        if let tracks {
            return tracks.results
        }
        
        return []
    }
    
    var canLoadMore: Bool {
        return self.totalResults > (self.page + 1) * perPage
    }
    
    enum CodingKeys: CodingKey {
        case page
        case perPage
        case tracks
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.page = try container.decode(Int.self, forKey: .page)
        self.perPage = try container.decode(Int.self, forKey: .perPage)
        self.tracks = try container.decodeIfPresent(YandexMusicTracks.self, forKey: .tracks)
    }
}

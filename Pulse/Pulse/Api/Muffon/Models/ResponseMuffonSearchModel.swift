//
//  ResponseMuffonSearchModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import Foundation

final class ResponseMuffonSearchModel: Decodable {
    let search: MuffonSearchInfo
    
    enum CodingKeys: CodingKey {
        case search
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.search = try container.decode(MuffonSearchInfo.self, forKey: .search)
    }
}

typealias MuffonSearchInfo = ResponseMuffonSearchInfoModel

final class ResponseMuffonSearchInfoModel: Decodable {
    let page: Int
    let totalPages: Int?
    fileprivate let tracks: [MuffonTrack]
    
    var results: [Decodable] {
        return tracks
    }
    
    enum CodingKeys: String, CodingKey {
        case page
        case totalPages = "total_pages"
        case tracks
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.page = try container.decode(Int.self, forKey: .page)
        self.totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
        self.tracks = try container.decode([MuffonTrack].self, forKey: .tracks)
    }
}

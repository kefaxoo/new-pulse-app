//
//  ResponseYandexMusicTrackModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 14.12.23.
//

import Foundation

final class ResponseYandexMusicTrackModel: Decodable {
    fileprivate let coverUri: String?
    
    let id         : Int
    let title      : String
    let isAvailable: Bool
    let artists    : [YandexMusicArtist]
    let albums     : [YandexMusicAlbum]
    let lyricsInfo : YandexMusicLyricsInfo
    let isExplicit : Bool
    
    func coverLink(for size: YandexMusicCoverType) -> String {
        guard let coverUri else { return "" }
        
        return "https://\(coverUri.replacingOccurrences(of: "%%", with: size.rawValue))"
    }
    
    enum CodingKeys: String, CodingKey {
        case coverUri
        case id
        case title
        case isAvailable = "available"
        case artists
        case albums
        case lyricsInfo
        case isExplicit = "explicit"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.coverUri = try container.decodeIfPresent(String.self, forKey: .coverUri)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.isAvailable = try container.decode(Bool.self, forKey: .isAvailable)
        self.artists = try container.decode([YandexMusicArtist].self, forKey: .artists)
        self.albums = try container.decode([YandexMusicAlbum].self, forKey: .albums)
        self.lyricsInfo = try container.decode(YandexMusicLyricsInfo.self, forKey: .lyricsInfo)
        self.isExplicit = try container.decode(Bool.self, forKey: .isExplicit)
    }
}

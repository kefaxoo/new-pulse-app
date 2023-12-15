//
//  ResponseYandexMusicAlbumModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 14.12.23.
//

import Foundation

final class ResponseYandexMusicAlbumModel: Decodable {
    fileprivate let coverUri: String?
    
    let id           : Int
    let title        : String
    let releaseDate  : String?
    let recent       : Bool
    let artists      : [YandexMusicArtist]
    let labels       : [YandexMusicAlbumLabel]
    let isAvailable  : Bool
    let trackPosition: YandexMusicTrackPosition
    let isExplicit   : Bool
    
    func coverLink(for size: YandexMusicCoverType) -> String {
        guard let coverUri else { return "" }
        
        return "https://\(coverUri.replacingOccurrences(of: "%%", with: size.rawValue))"
    }
    
    enum CodingKeys: String, CodingKey {
        case coverUri
        case id
        case title
        case releaseDate
        case recent
        case artists
        case labels
        case isAvailable = "available"
        case trackPosition
        case isExplicit = "contentWarning"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.coverUri = try container.decodeIfPresent(String.self, forKey: .coverUri)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        self.recent = try container.decode(Bool.self, forKey: .recent)
        self.artists = try container.decode([YandexMusicArtist].self, forKey: .artists)
        self.labels = try container.decode([YandexMusicAlbumLabel].self, forKey: .labels)
        self.isAvailable = try container.decode(Bool.self, forKey: .isAvailable)
        self.trackPosition = try container.decode(YandexMusicTrackPosition.self, forKey: .trackPosition)
        if let isExplicit = try? container.decodeIfPresent(String.self, forKey: .isExplicit) {
            self.isExplicit = Bool(isExplicit) ?? false
        } else {
            self.isExplicit = false
        }
    }
}

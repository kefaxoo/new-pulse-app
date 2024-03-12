//
//  ResponsePulseExclusiveTrackModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 3.01.24.
//

import Foundation

final class ResponsePulseExclusiveTrackModel: Decodable {
    enum Labels: String {
        case lossless
        case dolbyAtmos
        case hiResLossless
        case none = ""
        
        var trackLabel: TrackModel.Labels {
            switch self {
                case .lossless:
                    return .lossless
                case .dolbyAtmos:
                    return .dolbyAtmos
                case .hiResLossless:
                    return .hiResLossless
                case .none:
                    return .none
            }
        }
    }
    
    let id             : Int
    let title          : String
    let artists        : [ResponsePulseExclusiveArtistModel]?
    let album          : ResponsePulseExclusiveAlbumModel?
    let releaseDate    : String?
    let trackNumber    : Int
    let diskNumber     : Int
    let isExplicit     : Bool
    let subtitle       : String?
    let playableLink   : String
    let yandexMusicId  : Int?
    let spotifyId      : String?
    let canvasLink     : String?
    let trackExtension : String
    let labels         : [Labels]
    let nowPlayingLabel: Labels?
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case artists
        case album
        case releaseDate
        case trackNumber
        case diskNumber
        case isExplicit
        case subtitle
        case playableLink
        case yandexMusicId
        case spotifyId
        case canvasLink
        case trackExtension
        case labels
        case nowPlayingLabel
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.artists = try container.decodeIfPresent([ResponsePulseExclusiveArtistModel].self, forKey: .artists)
        self.album = try container.decodeIfPresent(ResponsePulseExclusiveAlbumModel.self, forKey: .album)
        self.releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        self.trackNumber = try container.decode(Int.self, forKey: .trackNumber)
        self.diskNumber = try container.decode(Int.self, forKey: .diskNumber)
        self.isExplicit = try container.decode(Bool.self, forKey: .isExplicit)
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        self.playableLink = try container.decode(String.self, forKey: .playableLink)
        self.yandexMusicId = try container.decodeIfPresent(Int.self, forKey: .yandexMusicId)
        self.spotifyId = try container.decodeIfPresent(String.self, forKey: .spotifyId)
        self.canvasLink = try container.decodeIfPresent(String.self, forKey: .canvasLink)
        self.trackExtension = try container.decode(String.self, forKey: .trackExtension)
        if let labelsRaw = try? container.decodeIfPresent([String].self, forKey: .labels) {
            self.labels = labelsRaw.map({ Labels(rawValue: $0) ?? .none }).filter({ $0 != .none })
        } else {
            self.labels = []
        }
        
        if let nowPlayingLabelRaw = try? container.decode(String.self, forKey: .nowPlayingLabel) {
            self.nowPlayingLabel = Labels(rawValue: nowPlayingLabelRaw)
        } else {
            self.nowPlayingLabel = nil
        }
    }
}

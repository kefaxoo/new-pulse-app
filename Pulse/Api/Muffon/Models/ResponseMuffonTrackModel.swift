//
//  ResponseMuffonTrackModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.09.23.
//

import Foundation

final class ResponseMuffonTrackInfoModel: Decodable {
    let trackInfo: MuffonTrack
    
    enum CodingKeys: String, CodingKey {
        case trackInfo = "track"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.trackInfo = try container.decode(MuffonTrack.self, forKey: .trackInfo)
    }
}

final class ResponseMuffonTrackModel: Decodable {
    let source : MuffonSource
    let title  : String
    let artist : MuffonArtist
    let artists: [MuffonArtist]
    let image  : MuffonImage?
    let audio  : MuffonAudio
    
    var `extension`: String {
        return source.service == .spotify ? "ogg" : "mp3"
    }
    
    enum CodingKeys: CodingKey {
        case source
        case title
        case artist
        case artists
        case image
        case audio
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.source = try container.decode(MuffonSource.self, forKey: .source)
        self.title = try container.decode(String.self, forKey: .title)
        self.artist = try container.decode(MuffonArtist.self, forKey: .artist)
        self.artists = try container.decode([MuffonArtist].self, forKey: .artists)
        self.image = try container.decodeIfPresent(MuffonImage.self, forKey: .image)
        self.audio = try container.decode(MuffonAudio.self, forKey: .audio)
    }
}

typealias MuffonAudio = ResponseMuffonAudioModel

final class ResponseMuffonAudioModel: Decodable {
    let isAvailable: Bool
    let link       : String?
    
    enum CodingKeys: String, CodingKey {
        case isAvailable = "present"
        case link
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.isAvailable = try container.decode(Bool.self, forKey: .isAvailable)
        self.link = (try container.decodeIfPresent(String.self, forKey: .link))?.replacingOccurrences(of: "\\u0026", with: "&")
    }
}

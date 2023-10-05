//
//  ResponseSoundcloudPlaylistModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 22.09.23.
//

import Foundation

final class ResponseSoundcloudPlaylistModel: Decodable {
    fileprivate let createdAt: String
    fileprivate let updatedAt: String
    
    let duration           : Int
    let shareLink          : String
    let playlistDescription: String?
    let tracksCount        : Int
    let user               : SoundcloudUser
    let id                 : Int
    let title              : String
    let artworkLink        : String?
    
    var dateCreated: Int {
        return Int(self.createdAt.toDate(format: "YYYY/MM/dd HH:mm:SS '+'0000")?.timeIntervalSince1970 ?? -1)
    }
    
    var dateUpdated: Int {
        return Int(self.updatedAt.toDate(format: "YYYY/MM/dd HH:mm:SS '+'0000")?.timeIntervalSince1970 ?? -1)
    }
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "last_modified"
        case duration
        case shareLink           = "permalink_url"
        case playlistDescription = "description"
        case tracksCount         = "track_count"
        case user
        case id
        case title
        case artworkLink = "artwork_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
        self.duration = try container.decode(Int.self, forKey: .duration)
        self.shareLink = try container.decode(String.self, forKey: .shareLink)
        self.playlistDescription = try container.decodeIfPresent(String.self, forKey: .playlistDescription)
        self.tracksCount = try container.decode(Int.self, forKey: .tracksCount)
        self.user = try container.decode(SoundcloudUser.self, forKey: .user)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.artworkLink = try container.decodeIfPresent(String.self, forKey: .artworkLink)
    }
}

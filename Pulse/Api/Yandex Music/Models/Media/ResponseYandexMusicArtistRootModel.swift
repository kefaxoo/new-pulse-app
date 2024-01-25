//
//  ResponseYandexMusicArtistRootModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.12.23.
//

import Foundation

final class ResponseYandexMusicArtistRootModel: Decodable {
    let artist: YandexMusicArtist
    let albums: [YandexMusicAlbum]?
    let popularTracks: [YandexMusicTrack]?
    let similarArtists: [YandexMusicArtist]?
    let allCovers: [YandexMusicCover]?
    let lastReleases: [YandexMusicAlbum]?
    let playlists: [YandexMusicPlaylist]?
    
    enum CodingKeys: CodingKey {
        case artist
        case albums
        case popularTracks
        case similarArtists
        case allCovers
        case lastReleases
        case playlists
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
     
        self.artist = try container.decode(YandexMusicArtist.self, forKey: .artist)
        self.albums = try container.decodeIfPresent([YandexMusicAlbum].self, forKey: .albums)
        self.popularTracks = try container.decodeIfPresent([YandexMusicTrack].self, forKey: .popularTracks)
        self.similarArtists = try container.decodeIfPresent([YandexMusicArtist].self, forKey: .similarArtists)
        self.allCovers = try container.decodeIfPresent([YandexMusicCover].self, forKey: .allCovers)
        self.lastReleases = try container.decodeIfPresent([YandexMusicAlbum].self, forKey: .lastReleases)
        self.playlists = try container.decodeIfPresent([YandexMusicPlaylist].self, forKey: .playlists)
    }
}

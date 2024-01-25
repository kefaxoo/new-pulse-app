//
//  ArtistViewScheme.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 28.12.23.
//

import Foundation

enum ArtistViewScheme: Int {
    case albums = 3
    case popularTracks = 2
    case similarArtists = 5
    case lastRelease = 1
    case playlists = 4
    
    var headerTitle: String? {
        switch self {
            case .popularTracks:
                return Localization.Enums.Media.ArtistViewScheme.HeaderTitle.popularTracks.localization
            default:
                return nil
        }
    }
    
    var cellId: String {
        switch self {
            case .popularTracks:
                return TrackTableViewCell.id
            default:
                return ""
        }
    }
}

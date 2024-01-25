//
//  LibraryPlaylistType.swift
//  Pulse
//
//  Created by ios on 12.10.23.
//

import Foundation

enum LibraryPlaylistType {
    case user
    case liked
    
    var title: String {
        switch self {
            case .user:
                return Localization.Lines.yourPlaylists.localization
            case .liked:
                return Localization.Lines.likedPlaylists.localization
        }
    }
}

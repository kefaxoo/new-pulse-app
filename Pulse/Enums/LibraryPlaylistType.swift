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
                return "Your playlists"
            case .liked:
                return "Liked playlists"
        }
    }
}

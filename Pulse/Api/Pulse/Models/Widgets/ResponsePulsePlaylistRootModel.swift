//
//  ResponsePulsePlaylistRootModel.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 17.01.24.
//

import Foundation

class ResponsePulsePlaylistRootModel: PulseBaseSuccessModel {
    let playlist: PulsePlaylist
    
    enum CodingKeys: CodingKey {
        case playlist
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.playlist = try container.decode(PulsePlaylist.self, forKey: .playlist)
        
        try super.init(from: decoder)
    }
}

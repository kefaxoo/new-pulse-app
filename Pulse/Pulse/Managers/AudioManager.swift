//
//  AudioManager.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 7.09.23.
//

import Foundation

struct UpdatedTrack {
    let track   : TrackModel
    let response: Decodable
}

final class AudioManager {
    static let shared = AudioManager()
    
    fileprivate init() {}
    
    func updatePlayableLink(for track: TrackModel, success: @escaping((UpdatedTrack) -> ()), failure: @escaping(() -> ())) {
        switch track.service.source {
            case .muffon:
                MuffonProvider.shared.trackInfo(track) { muffonTrack in
                    let track = TrackModel(muffonTrack)
                    success(UpdatedTrack(track: track, response: muffonTrack))
                } failure: {
                    failure()
                }
            case .none:
                failure()
        }
    }
}
